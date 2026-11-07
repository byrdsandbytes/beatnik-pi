# Using the Beatnik Controller

Beatnik Controller is a web-based remote control for your Beatnik Pi or Snapcast multi-room audio server. It allows you to easily manage and control audio streams from any device with a web browser.

## Features

- Control volume for all connected clients.
- Manage client groups.
- View what's currently playing on each stream.
- Simple and intuitive user interface.

To run the controller yourself with Docker, see the [Controller Docker Setup](./controller-docker.md). 
## Usage Guide

A walkthrough of every feature, from first-time setup to day-to-day listening and device maintenance:

1. [Getting Around](./guide-getting-around.md) - concepts, connecting to your server and the app layout.
2. [Everyday Use](./guide-everyday-use.md) - dashboard, devices, streams and presets.
3. [Adding a New Beatnik Device](./guide-add-device.md) - Wi-Fi, server, audio and group setup.
4. [Camilla DSP and Equalising](./guide-camilladsp.md) - EQ, master volume, mixers, dynamics and config files.
5. [Device Maintenance & Updates](./guide-maintenance.md) - device details, updates, server status and the network scanner.
6. [Settings & Help](./guide-settings-help.md) - settings, demo mode, web vs. mobile app and troubleshooting.

The Beatnik Controller app is available for both iOS and Android devices, as well as selfhosted WebApp. It allows you to setup, configure, and control your Beatnik audio system, including grouping speakers, adjusting volume, EQ settings, and checking the status of your devices.

## iOS & Android App

- **iOS:** [Download from the App Store](https://apps.apple.com/ch/app/beatnik-audio/)
- **Android:** [Download from Google Play](https://play.google.com/store/apps/details?id=ch.byrds.beatnik)
- **Source Code:** [GitHub Repository](https://github.com/byrdsandbytes/beatnik-controller)

<img src="../images/app_mulitroomControll.webp" alt="Beatnik Controller App - Multiroom Volume Control" />
<img src="../images/app_camillaDSP.webp" alt="Beatnik Controller App CamillaDSP" />
<img src="../images/app_soundcard_pick.webp" alt="Beatnik Controller App - Soundcard Selection" />

## Selfhosted WebApp

<img src="../images/webApp001.webp" alt="Beatnik Controller Web UI" />
<img src="../images/webApp002.webp" alt="Beatnik Controller Web UI - Speaker Grouping" />
<img src="../images/webApp003.webp" alt="Beatnik Controller Web UI - EQ Settings" />

The Beatnik Controller Web UI allows you to manage your Beatnik audio system from any web browser. You can group speakers, adjust volume, configure EQ settings, and monitor the status of your devices.

Your Beatnik server spawns a web interface (using Docker) that you can access through your browser to manage and control your audio system without needing to use the mobile app.

- **Access:** Open a web browser and navigate to the IP address or hostname of your Beatnik server, e.g. `http://192.168.1.100` or `http://beatnik-042.local/`

Make sure your browser is on the same network as your Beatnik server and has network access to your local network.
