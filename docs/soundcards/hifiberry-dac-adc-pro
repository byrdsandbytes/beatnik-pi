# HiFiBerry DAC 2 ADC Pro

This card provides both a high-quality analog output (DAC) and a high-quality analog input (ADC), making it ideal for integrating external audio sources like a turntable into your Snapcast system.

## Driver Activation

To enable the driver, you need to edit the `/boot/firmware/config.txt` file.

1.  **Open the configuration file:**
    ```bash
    sudo nano /boot/firmware/config.txt
    ```

2.  **Disable the onboard audio** by removing or commenting out this line (if it exists):
    ```ini
    # dtparam=audio=on
    ```

3.  **Add the DAC+ ADC Pro overlay:**
    ```ini
    dtoverlay=hifiberry-dacplusadcpro
    ```

4.  **Ensure the HDMI audio is also disabled** by modifying the `vc4-kms-v3d` line to include `noaudio`:
    ```ini
    dtoverlay=vc4-kms-v3d,noaudio
    ```

5.  **Reboot** to apply the changes:
    ```bash
    sudo reboot
    ```

6.  **Verify** that the card is detected correctly after rebooting:
    ```bash
    aplay -l
    ```
    You should see a device named `snd_rpi_hifiberry_dacplusadcpro` in the list.

## Key Features
- **Stereo Analog Output:** Dedicated 192kHz/24bit high-quality Burr-Brown DAC.
- **Stereo Analog Input:** Dedicated 192kHz/24bit high-quality Burr-Brown ADC.

## Links
- **Product Page:** https://www.hifiberry.com/shop/boards/hifiberry-dac-adc-pro/
- **Datasheet:** https://www.hifiberry.com/docs/data-sheets/datasheet-dac2-adc-pro/
- **Software Guide:** https://www.hifiberry.com/docs/software/configuring-linux-3-18-x/