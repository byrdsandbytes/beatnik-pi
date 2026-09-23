# HiFiBerry Digi+ / Digi 2 Standard

## Driver Activation

Based on HiFiBerry docs: https://www.hifiberry.com/docs/software/configuring-linux-3-18-x/

```bash
sudo nano /boot/firmware/config.txt
```

**Remove** the line: 
```
dtparam=audio=on
```

Add **instead**:

```ini
dtoverlay=hifiberry-digi
```

Scroll down and find this line:

```
dtoverlay=vc4-kms-v3d
```

add "noaudio" and make sure it looks exactly like this:

```
dtoverlay=vc4-kms-v3d,noaudio
```

Reboot:

```bash
sudo reboot
```

SSH back in, then verify:

```bash
aplay -l   # must list "sndrpihifiberry"
```
