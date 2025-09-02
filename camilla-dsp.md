# Advanced: Room Correction with CamillaDSP

This tutorial guides you through setting up CamillaDSP on a Raspberry Pi Snapcast client. The goal is to process the audio stream from your Snapserver with CamillaDSP for equalization or room correction before playing it on the client's DAC.

This setup uses a virtual **ALSA Loopback** device, which acts like a software audio cable to route audio between applications.

### The Audio Path

> Snapclient → ALSA Loopback (Input) → CamillaDSP (Processing) → ALSA Loopback (Output) → Your DAC

---

## Prerequisites

Before you begin, ensure you have:

- A Raspberry Pi (4 or 5 recommended) running a 64-bit version of Raspberry Pi OS (Bookworm).
- A working Snapclient installation connected to your Snapserver.
- A DAC (Digital-to-Analog Converter) connected to your Pi.
- An active SSH session to your client Pi.

---

## Step 1: Install CamillaDSP and Dependencies

First, let's get the necessary software installed on your client Pi.

### 1.1. Create Directories for CamillaDSP

Organize your configuration and filter files.

```bash
mkdir -p ~/camilladsp/configs ~/camilladsp/coeffs
```

### 1.2. Install ALSA Utilities

This provides tools for managing your audio devices.

```bash
sudo apt-get update
sudo apt-get install -y alsa-utils
```

### 1.3. Download and Install CamillaDSP

Fetch the latest `aarch64` binary from the official releases page and place it in `/usr/local/bin/`.

```bash
wget https://github.com/HEnquist/camilladsp/releases/download/v2.0.3/camilladsp-linux-aarch64.tar.gz -P ~/camilladsp/
sudo tar -xvf ~/camilladsp/camilladsp-linux-aarch64.tar.gz -C /usr/local/bin/
```

---

## Step 2: Create the Virtual Audio Cable (ALSA Loopback)

To route audio from Snapclient to CamillaDSP, we need to create a virtual sound card.

### 2.1. Load the Kernel Module

This command loads the `snd-aloop` module, which creates the loopback device.

```bash
sudo modprobe snd-aloop
```

### 2.2. Make it Permanent

To ensure the module loads on every reboot, create a configuration file.

```bash
echo "snd-aloop" | sudo tee /etc/modules-load.d/snd-aloop.conf
```

### 2.3. Verify the Device

Check that the virtual card was created successfully.

```bash
aplay -l
```

You should see a new card in the list, typically named `Loopback`.

---

## Step 3: Configure Snapclient for Loopback

Instruct Snapclient to send its audio to the input of our virtual cable instead of directly to your DAC.

### 3.1. Edit the Snapclient Configuration

```bash
sudo nano /etc/snapclient.conf
```

### 3.2. Set the Output Sound Device

Find the `sound_device` line (it may be commented out with a `#`). Change it to point to the first subdevice of the Loopback card. Using the `plughw` plugin is more robust and helps avoid "device busy" errors.

```ini
# /etc/snapclient.conf

# The soundcard to use, find the correct one with "snapclient -l"
sound_device = plughw:Loopback,0,0
```

### 3.3. Restart Snapclient

Apply the new configuration.

```bash
sudo systemctl restart snapclient
```

---

## Step 4: Configure CamillaDSP

Create the CamillaDSP configuration file. This will tell it to:
1.  **Capture** audio from the output of the virtual cable.
2.  **Process** the audio with your desired filters.
3.  **Playback** the final audio to your real DAC.

### 4.1. Create the CamillaDSP Configuration File

```bash
nano ~/camilladsp/configs/client_config.yml
```

### 4.2. Add the Configuration

Copy and paste this entire block into the file. **Important:** You must change the `playback` device to match your DAC's name from the `aplay -l` command.

```yaml
# ~/camilladsp/configs/client_config.yml

devices:
  samplerate: 48000
  chunksize: 1024
  capture:
    type: Alsa
    channels: 2
    device: "hw:Loopback,1,0" # Capture from the other end of the loopback
    format: S16LE
  playback:
    type: Alsa
    channels: 2
    device: "plughw:CARD=DigiAMP,DEV=0" # IMPORTANT: Set this to your real DAC
    format: S16LE

filters:
  # This is a placeholder filter that does nothing.
  # You can add your real EQ/filter settings here later.
  example_filter:
    type: Biquad
    parameters:
      type: Peaking
      freq: 1000
      q: 0.7
      gain: 0.0

pipeline:
  - type: Filter
    channel: 0
    names:
      - example_filter
  - type: Filter
    channel: 1
    names:
      - example_filter
```

---

## Step 5: Create and Run the CamillaDSP Service

To make this setup robust, we'll run CamillaDSP as a `systemd` service that automatically starts after Snapclient.

### 5.1. Create the Service File

```bash
sudo nano /etc/systemd/system/camilladsp.service
```

### 5.2. Add the Service Configuration

This configuration ensures `snapclient` is running before `camilladsp` starts. **Replace `<your_user>`** with your actual username (e.g., `pi`).

```ini
# /etc/systemd/system/camilladsp.service

[Unit]
Description=CamillaDSP
# This ensures snapclient is started first
Wants=snapclient.service
After=snapclient.service

[Service]
Type=simple
User=<your_user>
ExecStart=/usr/local/bin/camilladsp /home/<your_user>/camilladsp/configs/client_config.yml -p 1234
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target
```

### 5.3. Reload, Enable, and Restart Services

This applies all your changes.

```bash
sudo systemctl daemon-reload
sudo systemctl enable camilladsp
sudo systemctl restart snapclient
sudo systemctl restart camilladsp
```

### 5.4. Check the Status

Verify that both services are running without errors.

```bash
sudo systemctl status snapclient
sudo systemctl status camilladsp
```

If both are `active (running)`, you're all set! Start playing audio from your Snapserver, and it should now be processed by CamillaDSP on your client before you hear it.


---

## Step 6: Install and Configure the Web GUI (Optional)

CamillaGUI provides a powerful web interface to control CamillaDSP in real-time. This allows you to adjust volume, mute, select configurations, and view a live spectrum analyzer from any device on your network.

### 6.1. Install Dependencies

We only need `unzip` for the frontend files.

```bash
sudo apt-get update
sudo apt-get install -y unzip
```

### 6.2. Download the GUI Components

We'll create a dedicated directory and download the latest versions of the backend binary and the frontend web files.

```bash
# Create the directory
mkdir -p ~/camillagui
cd ~/camillagui

# Download the backend binary for 64-bit ARM (aarch64)
wget https://github.com/HEnquist/camillagui-backend/releases/latest/download/camillagui-backend-linux-aarch64.tar.gz

# Download the frontend web interface
wget https://github.com/HEnquist/camillagui/releases/latest/download/camillagui.zip

# Extract both components
tar -xvf camillagui-backend-linux-aarch64.tar.gz
unzip camillagui.zip
```

### 6.3. Test the GUI Manually (Crucial Step)

Before creating a service, it's vital to test that the GUI server can run correctly.

1.  **Make sure you are in the `~/camillagui` directory.**
2.  **Run the server manually:**
    ```bash
    ./camillagui-backend
    ```
3.  **Open a web browser** on your computer (on the same network) and go to:
    `http://<your-pi-ip-address>:5000`

You should see the CamillaGUI interface. If it works, you can stop the manual server by pressing `Ctrl+C` in your SSH session.

### 6.4. Create the `systemd` Service for the GUI

Once the manual test works, we can create a service to run it automatically.

```bash
sudo nano /etc/systemd/system/camillagui.service
```

Paste the following configuration. **Remember to replace `<your_user>`** with your actual username (e.g., `byrds` or `pi`).

```ini
# /etc/systemd/system/camillagui.service

[Unit]
Description=CamillaDSP GUI
# Start after the main camilladsp service
Wants=camilladsp.service
After=camilladsp.service

[Service]
Type=simple
User=<your_user>
# The executable must be run from this directory to find the frontend files
WorkingDirectory=/home/<your_user>/camillagui
ExecStart=/home/<your_user>/camillagui/camillagui-backend
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

### 6.5. Enable and Start the GUI Service

Now, enable the service to start on boot and start it immediately.

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now camillagui.service
```

### 6.6. Final Verification

Check that the service is running correctly:
```bash
sudo systemctl status camillagui.service
```
If it shows `active (running)`, you can now access the GUI permanently at `http://<your-pi-ip-address>:5000`.
