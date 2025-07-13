# HifiBerry Amp 4 Pro


## Driver Actication

Based on hifi berry docs: https://www.hifiberry.com/docs/software/configuring-linux-3-18-x/

```bash
sudo nano /boot/firmware/config.txt
```



**Remove** the line: 
```
dtparam=audio=on
```

Add **instead**:

```ini
dtoverlay=hifiberry-amp4pro
```
Scorll down and find this line:

```
dtoverlay=vc4-kms-v3d
```

add "noaudio" and makesure it looks exactly like this:

```
dtoverlay=vc4-kms-v3d,noaudio
```



Reboot, 

```
sudo reboot
```
SSH back in,then verify:

```bash
aplay -l   # must list "sndrpihifiberry"
```

## Specs
- Output: 2 x 60W


## Links
- Product: 
- Docs:  https://www.hifiberry.com/docs/software/configuring-linux-3-18-x/




