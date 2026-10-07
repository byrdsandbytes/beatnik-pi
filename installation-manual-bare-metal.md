# Beatnik Manual / Bare Metal Installation

## 1 · Flash OS & SSH into the Pi

1. **Download** [Raspberry Pi Imager](https://www.raspberrypi.com/software/).
2. Select **Raspberry Pi OS Lite (64‑bit, Bookworm)**.
3. In *OS customisation*:

   * **Enable SSH** and add your credentials (eg. user: beatnik, pw: changeMe)
   * **Hostname:** `beatnik-server`
   * *(Optional)* enter Wi‑Fi credentials if you plan using Wi-Fi
4. Flash the card, insert it, boot up the Pi.

### SSh into the pi 

```bash
ssh beatnik@beatnik-server.local
sudo apt update && sudo apt full-upgrade -y
```

---

## 2 · Activate Drivers (HIFI Berry Amp 4 example)

**NOTE:** If you're using a diffent soundcard (DAC/amp) check the [soundcard folder in the docs](./docs/soundcards)

Based on hifi berry docs: https://www.hifiberry.com/docs/software/configuring-linux-3-18-x/

```bash
sudo nano /boot/firmware/config.txt
```



**Remove** the line: 
```
dtparam=audio=on
```

Add **instead**:

```ini
dtoverlay=hifiberry-amp4pro
```
Scorll down and find this line:

```
dtoverlay=vc4-kms-v3d
```

add "noaudio" and makesure it looks exactly like this:

```
dtoverlay=vc4-kms-v3d,noaudio
```



Reboot, 

```
sudo reboot
```
SSH back in,then verify:

```bash
aplay -l   # must list "sndrpihifiberry"
```


---

## 3 · Install Snapcast 0.31

```bash
cd /tmp
wget https://github.com/badaix/snapcast/releases/download/v0.31.0/snapserver_0.31.0-1_arm64_bookworm.deb   https://github.com/badaix/snapcast/releases/download/v0.31.0/snapclient_0.31.0-1_arm64_bookworm.deb


sudo apt install ./snapserver_* ./snapclient_* -y
```

---
## 4 Install Streams (at least 1)

### 4.1 · Install Shairport‑Sync (AirPlay)

```bash
sudo apt install shairport-sync -y   # v4.3.x
```

> **Keep its systemd service disabled** – Snapserver will spawn its own instance.

```bash
sudo systemctl disable shairport-sync.service
```

---

### 4.2 . librespot using raspotify (Spotify Connect - expermintal)
I had some issues with installing librespot on debian boowkworm.
To install libresport withouht issues we will workaround using raspotify & afteerwards disable it. 



Run the installation script:
```bash
sudo apt-get -y install curl && curl -sL https://dtcooper.github.io/raspotify/install.sh | sh
```

Disable raspotify: (snapcast will spawn its own instance)


```bash
sudo systemctl disable raspotify
sudo systemctl stop raspotify
```



## 5 · Configure Snapserver

```bash
sudo nano /etc/snapserver.conf
```
In the strream section add your streams as follows:
(if you have trouble setting up your streams consult the sample snapserver.conf in this repo docs/sample-configs/sample-snapserver.conf)

### 5.1 Airplay 1 (uses port 5000)
More details here: https://github.com/badaix/snapcast/blob/develop/doc/configuration.md#airplay
```ini
[stream]
source = airplay:///usr/bin/shairport-sync?name=AirPlay&devicename=Beatnik-Airplay1&port=5000
```
### 5.2 Airplay 2 (uses port 7000)
More details here: https://github.com/badaix/snapcast/blob/develop/doc/configuration.md#airplay
```ini
[stream]
source = airplay:///shairport-sync?name=AirPlay2&devicename=Beatnik-Airplay2&port=7000
```

Find options for device names etc here: https://github.com/badaix/snapcast/blob/develop/doc/configuration.md

### 5.3 Spotify

```ini
[stream]
source = spotify:///librespot?name=Spotify&devicename=Beatnik-Spotify
```




---

## 6 · Point Snapclient at CamillaDSP (via ALSA Loopback)

Audio is processed by CamillaDSP before it reaches your amp (see [step 9](#9--beatnik-hardware-api) & [camilla-dsp.md](./camilla-dsp.md)), so Snapclient must send its audio into a virtual **ALSA Loopback** device instead of directly to your amp's sound card.

```bash
sudo usermod -aG audio snapclient   # grant ALSA access

# Create the virtual loopback cable Snapclient -> CamillaDSP
sudo modprobe snd-aloop
echo "snd-aloop" | sudo tee /etc/modules-load.d/snd-aloop.conf > /dev/null

sudo tee /etc/snapclient.conf >/dev/null <<'EOF'
[snapclient]
host         = localhost
sound_device = plughw:Loopback,0,0
# buffer       = 80            # optional client buffer (ms)
EOF
```

### 6.1 Find your amp's card number for CamillaDSP

CamillaDSP (not Snapclient) needs to know your amp's real soundcard, since it sits between the Loopback device and the amp. Check for your soundcard number:
```bash
 aplay -l 
```

Should list your soundcard like this:
```ini
**** List of PLAYBACK Hardware Devices ****
card 0: vc4hdmi [vc4-hdmi], device 0: MAI PCM i2s-hifi-0 [MAI PCM i2s-hifi-0]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: DigiAMP [RPi DigiAMP+], device 0: Raspberry Pi DigiAMP+ HiFi pcm512x-hifi-0 [Raspberry Pi DigiAMP+ HiFi pcm512x-hifi-0]
  Subdevices: 1/1
  Subdevice #0: subdevice #0

```

In this example our amp is card 1 (`DigiAMP`). Use that card name/number as the `playback` device in CamillaDSP's config — continue with [camilla-dsp.md](./camilla-dsp.md) to finish wiring CamillaDSP's capture (`hw:Loopback,1,0`) to this playback device.


---

## 7 · Start the services

```bash
sudo systemctl enable --now snapserver snapclient
```

Reboot the pi:

```bash
sudo reboot
```

Check live logs:

```bash
journalctl -u snapserver -f 
journalctl -u snapclient -f   # “… Connected to … hw:0,0 …”

```

---

## 8 · Beatnik Controller UI (selhosted)
For more information check the controller repo here: https://github.com/byrdsandbytes/beatnik-controller

### Prequesites
Docker & docker compose. If you have trouble setting up docker compose check our guide: [DOCKER_INSTALLATION.md](https://github.com/byrdsandbytes/beatnik-controller/docs/DOCKER_INSTALLATION.md)



### 8.1 Install using docker compose

Clone the repo:

```bash
git clone https://github.com/byrdsandbytes/beatnik-controller.git
cd beatnik-controller
```

```bash
docker compose up -d
```

This will build the Docker image and start the application in the background.

### 8.2 Access the Application

Open your web browser and navigate to `http://localhost:8181`, `http://beatnik-server.local:8181`  or `http://your-hostname.local:8181`. You should now see the Beatnik Controller interface.
  


### 8.4 (Optional find the classic snapwebclient UI here)

Open **[http://beatnik-server.local:1780](http://beatnik-server.local:1780)**

* **Streams** – should list *AirPlay*
* **Clients** – should list *audiopi* with live meters & volume

---

## 9 · Beatnik Hardware API

The Beatnik Hardware API is a small Node.js service that exposes hardware control & status (e.g. amp status) over HTTP. Full details are in the [beatnik-hardware-api repo](https://github.com/byrdsandbytes/beatnik-hardware-api).

> **Soundcard management:** The Hardware API takes over soundcard management (device selection & output routing) in combination with CamillaDSP (see [step 5](#5--configure-snapserver) & [camilla-dsp.md](./camilla-dsp.md)). CamillaDSP handles the audio processing/EQ pipeline, while the Hardware API coordinates which soundcard/output it routes to, so install both together rather than configuring the soundcard manually afterwards.

### Prerequisites

* **Node.js 22** — installed automatically via NVM by the setup script below (or manually, see the repo's guide, if you prefer)

### 9.1 Install (recommended: production setup script)

```bash
mkdir -p ~/beatnik-hardware-api
cd ~/beatnik-hardware-api
wget https://raw.githubusercontent.com/byrdsandbytes/beatnik-hardware-api/master/setup.sh
chmod +x setup.sh
./setup.sh
```

The script downloads the latest release artifact, installs Node.js 22 via NVM (if not already present), installs production dependencies, and installs/starts the `beatnik-hardware.service` systemd unit.

> Prefer building from source instead? See **Method 2: Manual Source Installation** in the [beatnik-hardware-api installation guide](https://github.com/byrdsandbytes/beatnik-hardware-api).

### 9.2 Check status

```bash
sudo systemctl status beatnik-hardware.service
curl http://localhost:3000/api/hardware/status
```

---

## 10 · Beatnik Bleno Service (optional)

The Beatnik Bleno service exposes Beatnik over Bluetooth Low Energy (BLE) for setup/control. Full details are in the [beatnik-bleno repo](https://github.com/byrdsandbytes/beatnik-bleno).

### Prerequisites

* **Node.js 22** — installed automatically via NVM by the setup script below (or manually, see the repo's guide, if you prefer)

### 10.1 Install (recommended: production setup script)

```bash
mkdir -p ~/beatnik-bleno
cd ~/beatnik-bleno
wget https://raw.githubusercontent.com/byrdsandbytes/beatnik-bleno/master/setup.sh
chmod +x setup.sh
./setup.sh
```

The script downloads the latest release artifact, installs Node.js 22 via NVM (if not already present), installs production dependencies, and installs/starts the `beatnik-bleno.service` systemd unit.

> Prefer building from source instead? See **Method 2: Manual Source Installation** in the [beatnik-bleno installation guide](https://github.com/byrdsandbytes/beatnik-bleno).

### 10.2 Check status

```bash
sudo systemctl status beatnik-bleno.service
sudo journalctl -u beatnik-bleno.service -f   # verify Bluetooth advertising and connections
```

---

## 11 · AirPlay test

* **macOS / appple  music**  → **AirPlay** 
* **iPhone / iPad** → apple music → **AirPlay** 
Snapweb flips to *playing* and audio starts after ≈ 0.4 s.

---

## 12 · Add more rooms

On another Pi (e.g. Pi Zero 2 W + MiniAmp):

### 12.1 Flash & first boot

*Imager settings*

```
OS           : Raspberry Pi OS Lite (32‑bit, Bookworm)
Hostname     : pizero-mini          # must be unique
SSH          : enabled
Wi‑Fi        : your credentials
```

```bash
ssh pi@pizero-mini.local
sudo passwd pi
sudo apt update && sudo apt full-upgrade -y
```

(Depending on your RAM this could take a while)

### 12.2 Enable the MiniAmp overlay

```bash
sudo nano /boot/firmware/config.txt
# add:
dtoverlay=hifiberry-dac           # MiniAmp overlay
```

Reboot and confirm `aplay -l` shows **sndrpihifiberry**.

### 12.3 Install Snapclient 0.31

```bash
cd /tmp
wget https://github.com/badaix/snapcast/releases/download/v0.31.0/snapclient_0.31.0-1_arm64_bookworm.deb
sudo apt install ./snapclient_* -y
```

### 12.4 Create a snapclient config

```bash
sudo usermod -aG audio snapclient

sudo tee /etc/snapclient.conf >/dev/null <<'EOF'
[snapclient]
host         = beatnik-server.local   # hostname of beatnik server pi
sound_device = hw:0,0          # card index from `aplay -l`
buffer       = 120             # Wi‑Fi cushion (ms)
EOF
```

### 12.5 Enable & start the client

```bash
sudo systemctl enable --now snapclient
journalctl -u snapclient -f   # look for “Connected to beatnik-server.local:1704 …”
```

---

Happy listening! 🎈
