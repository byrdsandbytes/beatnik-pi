# Raspberry Pi DAC+ HAT
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

Scorll down and find this line:

```
dtoverlay=vc4-kms-v3d
```

add "noaudio" and makesure it looks exactly like this:

```
dtoverlay=vc4-kms-v3d,noaudio
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
/proc/device-tree/hat/product:Raspberry Pi DAC Plus
/proc/device-tree/hat/product_id:0x0102
/proc/device-tree/hat/product_ver:0x0001
/proc/device-tree/hat/uuid:0e384c42-9138-4d3e-93c2-a4491999fefe
/proc/device-tree/hat/vendor:Raspberry Pi Ltd.
```

another test you can run

```bash
aplay -l  
```

should list something like this:

```ini
card 0: DAC [RPi DAC+], device 0: Raspberry Pi DAC+ HiFi pcm512x-hifi-0 [Raspberry Pi DAC+ HiFi pcm512x-hifi-0]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
```

### (Optional):
If you have an older model from "IQAudio" follow the guide here: https://www.raspberrypi.com/documentation/accessories/audio.html#hardware-versions



## Specs / Features (according to manufacturer)
- 24-bit 192kHZ high resolution audio
- Texas Instrumerns PCM5122 DAC to deliver stereo analogue audio to a pair of phono connectors
- Dedicated Headphone amplifier

## Links
- Product: https://www.raspberrypi.com/products/dac-plus
- Docs: https://www.raspberrypi.com/documentation/accessories/audio.html
