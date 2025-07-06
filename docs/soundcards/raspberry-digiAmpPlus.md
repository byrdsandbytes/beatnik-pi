# Raspberry Pi DigiAmp+ HAT
Former IQAudio

## Driver Actication

Based on raspberry docs: https://www.raspberrypi.com/documentation/accessories/audio.html

```bash
sudo nano /boot/firmware/config.txt
```



**Remove** the line: 
```
dtparam=audio=on
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
```bash
/proc/device-tree/hat/name:hat
/proc/device-tree/hat/product:Raspberry Pi DigiAMP+
/proc/device-tree/hat/product_id:0x0104
/proc/device-tree/hat/product_ver:0x0001
/proc/device-tree/hat/uuid:f030a72a-asdsad-asdsad-asdsad-add1c8a554de
/proc/device-tree/hat/vendor:Raspberry Pi Ltd.
```

another test you can run

```bash
aplay -l  
```

should list something like this:

```
card 1: DigiAMP [RPi DigiAMP+], device 0: Raspberry Pi DigiAMP+ HiFi pcm512x-hifi-0 [Raspberry Pi DigiAMP+ HiFi pcm512x-hifi-0]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
```
If you have an older model from "IQAudio" follow the guide here: LINK TO DO



## Specs
- Output: 2 x 35W

## Links
- Product: https://www.raspberrypi.com/products/digiamp-plus/
- Docs: https://www.raspberrypi.com/documentation/accessories/audio.html
