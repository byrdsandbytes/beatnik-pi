# Beatnik OS Installation Guide (Raspberry Pi Imager 2.x)

This guide explains how to flash our pre-configured **Beatnik OS** image using the **Raspberry Pi Imager v2** and the bratnik custom repository json file.

*NOTE: Raspberry Pi Imager v2 handles images differen than previous versions (1.X). In v2 you just need to download the beatnik-repo.json file and it will download the OS from here during flashing: https://github.com/byrdsandbytes/beatnik-pi/releases).*

## Prerequisites

1.  **Raspberry Pi Imager v2.x** or newer installed.
    -   Download: [raspberrypi.com/software](https://www.raspberrypi.com/software/)
2.  **beatnik-repo.json** file.
    -   Download the [`beatnik-repo.json`](beatnik-repo.json) file from this repository to your computer.

## Installation Steps

### 1. Load the Custom Repository
1.  Open **Raspberry Pi Imager**.
2.  Go to **Settings**.
3.  Navigate to **Image repository**.
4.  Select **Use own file**.
5.  Select the downloaded `beatnik-repo.json`.
6.  Select apply.

### 2. Select Device and OS
1.  Select your Raspberry Pi model.
2.  Select **Beatnik OS v0.4.9** (or the latest version shown).

### 3. Choose Storage
1.  Click **CHOOSE STORAGE**.
2.  Insert your SD card into your computer.
3.  Select the SD card from the list.

### 4. Configure OS Customisation 
*Raspberry Pi Imager 2.x allows you to pre-configure Wi-Fi and SSH. This is essential for a headless setup. *
*If you have a Beatnik LED Button you can skip this step and configure your pi using the app. 

1.  Click **NEXT**.
3.  **Customization**:
    -   **Set hostname**: e.g., `beatnik-001`.
    -   **Set username and password**: We recommend user `beatnik`. Choose a strong password.
    -   **Configure wireless LAN**: Enter your SSID and Password so the Pi connects automatically.
4.  **Services Tab**:
    -   **Enable SSH**: Check this box. Select **Use password authentication**.
5.  Click **SAVE**.

### 5. Flash
1.  Click **YES** to apply the customisation settings.
2.  Click **YES** to confirm erasing the SD card.
3.  Wait for the writing and verification process to complete.

## First Boot

1.  Insert the SD card into your Raspberry Pi.
2.  Power it on.
3.  The device will boot, resize the filesystem, and connect to your Wi-Fi.
4.  You can then access it via SSH or the web interface (if equipped):
    ```bash
    ssh beatnik@beatnik-001.local
    ```

*NOTE: Every BeatnikOS will first start as a SERVER you can degrade it to be a CLIENT it the App. (Check [Beatnik Controller Repo](https://github.com/byrdsandbytes/beatnik-controller))*
