# HiFiBerry Digi+ / Digi 2 Standard

[![Provenance](https://us-central1-human-validated-badge.cloudfunctions.net/badges/provenance/byrdsandbytes/beatnik-pi/docs/software/soundcards/hifiberry-digi.md)](https://github.com/byrdsandbytes/beatnik-pi/blob/master/docs/software/soundcards/hifiberry-digi.md)

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
