# Quick Start

Flash Beatnik OS to an SD card, then boot your Raspberry Pi.

## What You Need

- A Raspberry Pi
- An SD card
- [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
- The [Beatnik OS image repository file](https://github.com/byrdsandbytes/beatnik-pi/blob/master/beatnik-repo.json)

## Flash Beatnik OS

1. Open Raspberry Pi Imager.
2. In **Settings**, open **Image repository**, choose **Use own file**, and select `beatnik-repo.json`.
3. Select your Raspberry Pi model and the latest **Beatnik OS** version shown.
4. Choose your SD card.
5. Configure a hostname, username, password, Wi-Fi, and SSH access.
6. Start writing the image. This erases the SD card.
7. When writing and verification are complete, insert the SD card into your Raspberry Pi and power it on.

Beatnik OS starts as a server. You can change it to a client in the Beatnik Controller app.

For detailed instructions, see the [Beatnik OS Installation Guide](/software/flashing).
