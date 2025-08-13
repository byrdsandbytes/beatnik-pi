# IQ Audio DAC Pro
Now official Raspberry Pi DAC Pro
## Driver Actication

Based on raspberry docs: https://www.raspberrypi.com/documentation/accessories/audio.html

```bash
sudo nano /boot/firmware/config.txt
```



**Remove** the line: 
```
dtparam=audio=on
```

Scorll down and find this line:

```
dtoverlay=vc4-kms-v3d
```

add "noaudio" and makesure it looks exactly like this:

```
dtoverlay=vc4-kms-v3d,noaudio
```

add
```
dtoverlay=rpi-dacpro
```

Reboot the pi:

```bash
sudo reboot
```
SSH back in,then check the version of your hat:

```bash
grep -a . /proc/device-tree/hat/*
```

Should list your HAT something like this:
```ini
/proc/device-tree/hat/name:hat
/proc/device-tree/hat/product:Pi-DAC PRO
/proc/device-tree/hat/product_id:0x0008
/proc/device-tree/hat/product_ver:0x0003
/proc/device-tree/hat/uuid:f3d21f9f-64f4-4ee4-96aa-f779ea5cc2a9
/proc/device-tree/hat/vendor:IQaudIO Limited www.iqaudio.com
```

another test you can run

```bash
aplay -l  
```

should list something like this:

```ini
**** List of PLAYBACK Hardware Devices ****
card 0: IQaudIODAC [IQaudIODAC], device 0: IQaudIO DAC HiFi pcm512x-hifi-0 [IQaudIO DAC HiFi pcm512x-hifi-0]
  Subdevices: 1/1
  Subdevice #0: subdevice #0

```










## Links
- Product: https://www.raspberrypi.com/products/dac-pro
- Docs: https://www.raspberrypi.com/documentation/accessories/audio.html
