# How to Use an ADC as a Line-In for Snapcast

This guide explains how to use the Analog-to-Digital Converter (ADC) on a soundcard like the **HiFiBerry DAC+ ADC Pro** to create a line-in source for your Snapcast server. This allows you to stream audio from any analog device (e.g., a turntable, CD player, or phone) to all of your Snapcast clients.

### How It Works

The audio flows from your analog device through a chain of software components on the server:

> Analog Source → ADC Input → `arecord` (Capture) → Named Pipe (FIFO) → Snapserver → All Snapclients

---

## Prerequisites

- A working Snapcast server running on a Raspberry Pi.
- A soundcard with an ADC, like the [HiFiBerry DAC+ ADC Pro](docs/soundcards/hifiberry-dac-adc-pro.md), physically installed.
- The driver for your soundcard must be activated and working (see the soundcard docs).
- An analog audio source connected to the "Line In"  on your soundcard.

---

## Step 1: Find Your Capture Device

First, we need to identify the correct ALSA device name for your soundcard's input.

```bash
arecord -l
```

Look for your card in the output. The device name will be in the format `card X: CARDNAME [Device Long Name], device Y: ...`. You need the `CARDNAME` from this list.

For the HiFiBerry DAC+ ADC Pro, it will look something like this:

```
**** List of CAPTURE Hardware Devices ****
card 1: DACPLUSADCPRO [snd_rpi_hifiberry_dacplusadcpro], device 0: HiFiBerry DAC+ ADC Pro HiFi-0 [HiFiBerry DAC+ ADC Pro HiFi-0]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
```

From this, we can construct the full device name. The most reliable method is to use the card and device index numbers.

-   **Card Index:** `card 1` -> `1`
-   **Device Index:** `device 0` -> `0`

The ALSA device name is `hw:1,0`. **Note this down, as you will need it later.**

---

## Step 2: Create a Named Pipe

A named pipe (or FIFO) is a special file that acts as a buffer. We will write the captured audio into this pipe, and Snapserver will read it from the other end.

```bash
sudo mkfifo /tmp/snap-line-in
```

---

## Step 3: Add the Line-In Stream to Snapserver

Now, tell Snapserver to create a new stream that reads from the pipe we just created.

1.  **Edit the Snapserver configuration:**
    ```bash
    sudo nano /etc/snapserver.conf
    ```

2.  **Add a new `[stream]` source.** Add this block to the file, alongside your existing AirPlay and Spotify streams.
    ```ini
    [stream]
    source = pipe:///tmp/snap-line-in?name=Line-In&sampleformat=48000:16:2
    ```
    - `name=Line-In`: This is the name that will appear in your Snapcast client apps.
    - `sampleformat=48000:16:2`: This tells Snapserver to expect CD-quality stereo audio (48kHz sample rate, 16-bit depth, 2 channels).

---

## Step 4: Create a Service to Capture the Audio

To continuously capture audio from the ADC and feed it into the pipe, we'll create a `systemd` service.

1.  **Create the service file:**
    ```bash
    sudo nano /etc/systemd/system/snap-line-in.service
    ```

2.  **Add the following configuration.** This service will run the `arecord` command constantly.
    **IMPORTANT:** Replace `hw:CARD=DACPLUSADCPRO,DEV=0` with the device name you found in Step 1.

    ```ini
    [Unit]
    Description=Snapcast Line-In Capture Service
    Wants=snapserver.service
    After=snapserver.service

    [Service]
    Type=simple
    # IMPORTANT: Change the -D device to match your hardware from 'arecord -l'
    ExecStart=/usr/bin/arecord -D hw:1,0 -f S16_LE -r 48000 -c 2 /tmp/snap-line-in
    Restart=always2 /tmp/snap-line-in
    Restart=always
    RestartSec=1

    [Install]
    WantedBy=multi-user.target
    ```

---

## Step 5: Enable and Start Everything

Finally, enable the new service and restart Snapserver to apply all changes.

```bash
# Reload systemd to recognize the new service
sudo systemctl daemon-reload

# Enable the service to start on boot and start it now
sudo systemctl enable --now snap-line-in.service

# Restart snapserver to load the new stream configuration
sudo systemctl restart snapserver
```

## Step 6: Test It!

1.  Open your Snapcast control app (like Beatnik Controller or Snapweb). You should now see a new stream named **"Line-In"**.
2.  Select the "Line-In" stream for one of your client groups.
3.  Play some audio from your connected analog source.

The audio should now be playing across your selected Snapcast clients, perfectly in sync!




## Troubleshooting

### Service Fails to Start ("Start request repeated too quickly")

This error means the `arecord` command in your service file is failing immediately. Here’s how to find the real error and fix it.

**1. Check the Detailed Logs**

Run this command to see the exact error message from `arecord`:

```bash
journalctl -u snap-line-in.service
```

**2. Common Causes and Fixes**

-   **The Error:** `arecord: main:831: audio open error: No such device` or `Cannot get card index for...`
    -   **Cause:** The device name in your command (`-D hw:1,0`) is incorrect.
    -   **Fix:** Run `arecord -l` again and carefully check the `card X` and `device Y` numbers. Correct the `hw:X,Y` value in your `/etc/systemd/system/snap-line-in.service` file.

-   **The Error:** `arecord: main:831: unable to open audio device: Device or resource busy`
    -   **Cause:** Another application is already using the sound card's input.
    -   **Fix:** Find and stop the other process. You can check what's using your sound devices with `sudo fuser -v /dev/snd/*`.

-   **The Error:** `Rate 48000Hz not available for capture` or `Unsupported format`
    -   **Cause:** Your sound card doesn't support the exact sample rate or format requested.
    -   **Fix:** Try a different sample rate (e.g., `-r 44100`) or format (e.g., `-f S32_LE`) in your service file's `ExecStart` line. Remember to also update the `sampleformat` in your `/etc/snapserver.conf` to match!

After making any changes to the service file, remember to reload `systemd` and restart the service:

```bash
sudo systemctl daemon-reload
sudo systemctl restart snap-line-in.service
```