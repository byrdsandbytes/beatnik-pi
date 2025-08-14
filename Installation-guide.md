# Easy Installation Guide for Beatnik Pi

This guide provides step-by-step instructions for installing Beatnik Pi using the automated shell script. 

## Prerequisites

Before you begin, make sure you have the following:

- A **Raspberry Pi** (Pi 4 or 5 recommended for a server).
- An **SD card** flashed with the latest **Raspberry Pi OS** (64-bit recommended).
- A stable **internet connection** (Ethernet is recommended).
- Your chosen **soundcard or HAT** physically connected to the Raspberry Pi.

## Quick Installation Command

To start the installation, connect to your Raspberry Pi via SSH or open a terminal on the device and run the following single command. This will download and execute the installation script.

```bash
# 1. Download the installation script
wget https://raw.githubusercontent.com/byrdsandbytes/snapcast-pi/master/install.sh

# 2. Make the script executable
chmod +x install.sh

# 3. Run the installer
./install.sh
```

---

## The Guided Installation Process

The script will guide you through a few simple questions to configure your system. Here’s what to expect:

### Step 1: Choose Your Installation Type

You will first be asked what you want to install:

1.  **Full Beatnik Pi Server**: Choose this for your main device. It installs everything needed to host your multi-room audio system:
    - Snapcast Server (the core streamer)
    - Snapcast Client (to play audio on the server device itself)
    - AirPlay and Spotify Connect support
    - Optional Beatnik Controller web interface

2.  **Snapcast Client Only**: Choose this for all your other Raspberry Pis that will act as speakers in other rooms. It installs only the Snapcast client, which will connect to your main server.

### Step 2: Select Your Soundcard

Next, you'll see a list of supported soundcards and HATs.

```
1) HiFiBerry Amp4 Pro
2) Raspberry Pi DAC+ (former IQAudio)
3) Raspberry Pi DigiAmp+ (former IQAudio)
4) HiFiBerry MiniAmp (for clients)
5) Built-in 3.5mm jack
6) USB Audio Device
7) Other/Skip soundcard configuration
```

- **Choose the option** that matches your hardware.
- If you are using a **USB DAC**, make sure it is plugged in before running the script.
- If you choose the **built-in 3.5mm jack**, the script will ensure it's enabled.

### Step 3: Server Address (For Client Installations Only)

If you are installing a "Snapcast Client Only", the script will ask for the hostname or IP address of your main Beatnik Pi Server.

- Example: `beatnik-pi.local` or `192.168.1.50`.

### Step 4: Optional Web Interface (For Server Installations Only)

If you are installing a "Full Beatnik Pi Server", you will be asked if you want to install the **Beatnik Controller** web interface.

- It's highly recommended to install this (`y`) for a modern and easy-to-use control panel.

---

## What Happens Next?

Once you've answered the questions, the script will automate the rest:
- Update the system packages.
- Install all required software (Snapcast, AirPlay, Spotify, etc.).
- Configure the soundcard drivers in `/boot/firmware/config.txt`.
- Set up the Snapcast server and client configuration files.
- Enable and start all the necessary services.

## After Installation

The script will display a summary of what was installed and provide useful information.

- **Reboot**: For most soundcard configurations, the system will need to reboot to apply the changes. The script will do this automatically after a 10-second countdown.
- **Accessing the Server**:
  - **Beatnik Controller**: `http://<your-pi-hostname>.local:8181`
  - **Classic Snapweb UI**: `http://<your-pi-hostname>.local:1780`
- **Testing**:
  - From your phone or computer, look for a new **AirPlay** device named "Beatnik-Airplay".
  - Open the Spotify app and look for a new **Spotify Connect** device named "Beatnik-Spotify".

You are now ready to enjoy your multi-room audio system!
