# FAQ

Short answers with links to the full documentation.

## General & Ecosystem

### What is Beatnik?

Beatnik turns a Raspberry Pi into a Snapcast server that accepts AirPlay and Spotify Connect streams (from any smartphone, laptop or PC) and re-distributes them to any Snapclients you add later. The server itself also runs the first Snapclient, giving you an instant master room. See the [Project Overview](./project-overview.md).

### Is Beatnik really open source?

Yes. All the core components used in Beatnik Pi as well as the Beatnik Software are open source and freely available for anyone to use and modify. See the [Software Components](../advanced/architecture.md#software-components).

### How are Beatnik Pi and beatnik.audio related?

Beatnik Pi is the open-source software behind Beatnik. You can use it with hardware you source yourself, or find components, DIY bundles and assembled devices at [beatnik.audio](https://beatnik.audio).

## Hardware

### Do I need a DAC or an Amp setup?

Build an **Amp** if you have passive speakers (most vintage speakers are passive). Build a **DAC** if you have an existing music system, active speakers, an amp or a receiver. See [Choosing the Right Hardware](../hardware/choosing-hardware.md).

### Can I use my existing passive speakers?

Yes. The Amp has 4 binding posts as output. You can directly connect your passive speakers to those, using speaker wire (directly or using banana plugs).

### What is the difference between building it myself, a bundle and a Plug & Play device?

1. Build **everything from scratch**: organize everything yourself or order components from us, then install the software using the CLI or flash an SD card with BeatnikOS yourself.
2. Get a **curated bundle** with all the components and preinstalled software. You just have to assemble it, with IKEA-like manuals.
3. Get a **Plug & Play device** that just works. We assemble it for you, test everything in detail and ship it to you.

See [Choosing the Right Hardware](../hardware/choosing-hardware.md) and [How to Build a Beatnik Amplifier](../hardware/build-amplifier.md).

### Can I source my own Raspberry Pi and soundcard?

Yes. See the [Hardware Examples](../hardware/overview.md) for example parts lists. The soundcard configuration is described under [Soundcard Configuration (Bare Metal)](../software/soundcards/hifiberry-amp4Pro.md).

## Software & Features

### Which open-source software does Beatnik use?

Snapcast (Snapserver and Snapclient), Shairport-Sync (AirPlay), Librespot (Spotify Connect) and CamillaDSP (audio processing), plus the Beatnik Hardware API, Controller and Bleno service. See the [Software Components](../advanced/architecture.md#software-components).

### Which streams are supported?

AirPlay (1 & 2) and Spotify Connect are stable. See [AirPlay](../features/streaming/airplay.md), [Spotify Connect](../features/streaming/spotify.md) and [Line-In](../features/line-in.md).

### How does the multi-room synchronisation work?

The Snapserver receives the streams and distributes them to all Snapclients, which play them in sync. See the [Architecture](../advanced/architecture.md) and the [Audio Pipelines](../features/pipelines.md).

### Is there DSP or an equaliser?

Yes. [CamillaDSP](../features/dsp.md) runs on each Beatnik, and every device has its own EQ. See [Camilla DSP and Equalising](../usage/guide-camilladsp.md).

### How can I control the system?

With the Beatnik Controller: an iOS & Android app, or a self-hosted web app. See [Using the Beatnik Controller](../usage/controller.md).

### Can I try the app without any hardware?

Yes. **Menu > Enable Demo Mode** loads a mock server state with sample devices and streams. See [Settings & Help](../usage/guide-settings-help.md#demo-mode).

## Installation & Setup

### How difficult is the installation?

There are 3 paths: BeatnikOS (easy), the shell script (medium) and a bare metal / manual installation (hard). See the [Quick Start](./quick-start.md).

### How many devices can I sync on one network?

You can combine as many devices as you like. Currently we tested up to 23 devices in combination/sync.

### Where can I find the build manuals?

Start with [How to Build a Beatnik Amplifier](../hardware/build-amplifier.md).

## Troubleshooting

### The dashboard shows "Set Up Your Beatnik" or "Offline"

See the troubleshooting table in [Settings & Help](../usage/guide-settings-help.md#troubleshooting).

### A device is not found during setup

Hold the setup button for 5 seconds until the LED pulses blue, keep Bluetooth enabled and stay close to the device. See [Adding a New Beatnik Device](../usage/guide-add-device.md).

### Audio drops or is out of sync

See [Snapserver Buffering](../advanced/troubleshooting/snapserver-buffering.md) and the [Network Requirements](../software/network/requirements.md).

## Still stuck?

Ask the community on [r/beatnikAudio](https://www.reddit.com/r/beatnikAudio/) or open an issue on [GitHub](https://github.com/byrdsandbytes/beatnik-pi/issues).
