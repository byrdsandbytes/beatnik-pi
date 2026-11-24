# Updating from Beatnik 0.6 to 0.8

Beatnik 0.6 installed its own services from Git checkouts in your home folder. Beatnik 0.8 ships the Hardware API and the Bleno service as Debian packages that live in `/opt` and are managed by `apt`. The in-app updater can't make this switch for you, so you do it once by hand over SSH.

This guide removes the old checkouts and their systemd services, then installs the 0.8 packages. Your Snapcast, AirPlay and Spotify setup stays as it is.

::: tip Run this on every Beatnik device
Repeat the steps on **every** Beatnik device. Each one runs its own Snapserver, Hardware API and Bleno service.
:::

## Quick update with the script

The update script does every step below for you. SSH into the device and run:

```bash
wget https://raw.githubusercontent.com/byrdsandbytes/beatnik-pi/master/legacy/update-0-6-to-0-8.sh
chmod +x update-0-6-to-0-8.sh
./update-0-6-to-0-8.sh
```

Run it as your normal user (e.g. `beatnik`), not with `sudo`. It asks:

1. **Server or client.** A server runs Snapserver and plays audio itself. On a client, the script never enables or starts Snapserver.
2. **Self-host the Beatnik Controller.** Yes installs or updates the controller in `~/beatnik-controller` with Docker. No leaves it out, and if an old controller exists, asks whether to remove it.
3. **Confirmation** of a summary before anything changes, and at the end whether to reboot.

The script backs up `/etc/snapserver.conf` and your CamillaDSP config before changing them. Every device gets the 0.8 Snapserver config, but Snapclient settings stay as they are. On a client, the Line-In preamp service is turned off, since it only works together with Snapserver.

If you prefer to do it by hand, or the script stops with an error, follow the steps below.

## What changes

| Component | 0.6 | 0.8 |
|-----------|-----|-----|
| Hardware API | `~/beatnik-hardware-api` (installed with `setup.sh`) | `beatnik-hardware-api` package in `/opt/beatnik-hardware-api` |
| Bleno (Bluetooth setup, RGB button) | `~/beatnik-bleno` (installed with `setup.sh`, optional) | `beatnik-bleno` package in `/opt/beatnik-bleno` |
| CamillaDSP config | `~/camilladsp` | Comes with the Hardware API package, stored in `/var/lib/beatnik-hardware-api/camilladsp` |
| CamillaDSP executable | `/usr/local/bin/camilladsp` | Unchanged |
| Beatnik Controller | `~/beatnik-controller` (Docker) | Unchanged |

The service names (`beatnik-hardware.service`, `beatnik-bleno.service`, `camilladsp.service`) stay the same. The packages install their own unit files in place of the old ones.

## Before you start

- SSH into the device, e.g. `ssh beatnik@beatnik-server.local`.
- Make sure the device has internet access.
- Check that you're on a 64-bit OS. The Bleno package, which every device needs, only exists for `arm64`:

  ```bash
  dpkg --print-architecture   # must print arm64
  ```

## 1 · Check which old components are installed

```bash
ls -d ~/beatnik-hardware-api ~/beatnik-bleno ~/camilladsp ~/beatnik-controller 2>/dev/null
systemctl list-unit-files 'beatnik-*' 'camilladsp*'
dpkg -l | grep beatnik
```

If `dpkg -l` already lists `beatnik-hardware-api` or `beatnik-bleno`, that component was installed as a package earlier. Steps 4, 8 and 9 handle this, so just follow them as written.

`beatnik-bleno` is only present if you installed it in 0.6. Skip the removal steps for anything that isn't there. You still install both packages in steps 8 and 9.

## 2 · Back up your CamillaDSP config (optional)

If you changed EQ or filter settings in 0.6, keep a copy before deleting the folder:

```bash
cp ~/camilladsp/configs/client_config.yml ~/client_config.yml.0-6-backup
```

## 3 · Stop and disable the old services

```bash
sudo systemctl stop beatnik-hardware.service beatnik-bleno.service camilladsp.service
sudo systemctl disable beatnik-hardware.service beatnik-bleno.service camilladsp.service
```

If a service doesn't exist on this device, systemd reports `Unit ... not loaded`. You can ignore that.

## 4 · Remove the old unit files

The 0.6 scripts wrote their unit files directly to `/etc/systemd/system`, pointing at your home folder. Delete them so nothing still points at the old checkouts. The loop skips unit files that already belong to an installed package:

```bash
for unit in beatnik-hardware.service beatnik-bleno.service camilladsp.service; do
  file=/etc/systemd/system/$unit
  if [ -f "$file" ] && ! dpkg -S "$file" >/dev/null 2>&1; then
    echo "Removing $file"
    sudo rm -f "$file"
  fi
done
sudo systemctl daemon-reload
```

## 5 · Remove the old checkouts

```bash
rm -rf ~/beatnik-hardware-api ~/beatnik-bleno ~/camilladsp
```

::: warning Keep the controller folder
Don't delete `~/beatnik-controller`. The Beatnik Controller still runs from that folder in 0.8.
:::

## 6 · Install Node.js 22 as a system package

The packages need Node.js 22 or newer at `/usr/bin/node`. A Node.js installed through NVM doesn't count. Check what you have:

```bash
node --version
which node   # must be /usr/bin/node
```

If the version is below 22 or the path is different, install Node.js 22 from NodeSource:

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs
```

## 7 · Update the Snapserver config

The 0.6 Snapserver config only has AirPlay and Spotify. 0.8 adds a Line-In and an MPD source. The Hardware API package's preamp service waits for the Line-In pipe that Snapserver creates. Without it, the package install in step 8 hangs.

Back up your current config, then install the 0.8 configs and restart Snapserver:

```bash
sudo cp /etc/snapserver.conf /etc/snapserver.conf.0-6-backup
sudo wget -O /etc/snapserver.conf \
  https://raw.githubusercontent.com/byrdsandbytes/beatnik-pi/master/ci/snapserver.conf
sudo wget -O /etc/shairport-snapcast.conf \
  https://raw.githubusercontent.com/byrdsandbytes/beatnik-pi/master/ci/shairport-snapcast.conf
sudo systemctl restart snapserver.service
ls -l /tmp/snap-line-in   # must exist and start with "p" (a pipe)
```

If you changed device names or added sources in 0.6, copy those changes over from `/etc/snapserver.conf.0-6-backup`.

::: tip On a client
Install the two config files, but skip the `restart` and `ls` lines. Don't enable or start Snapserver on a client. Without Snapserver there's no Line-In pipe, so cap the preamp's start time before step 8. This keeps the install from hanging and is gone after the next reboot:

```bash
sudo mkdir -p /run/systemd/system/camilladsp-preamp.service.d
printf '[Service]\nTimeoutStartSec=5\n' | sudo tee /run/systemd/system/camilladsp-preamp.service.d/zz-update-guard.conf
sudo systemctl daemon-reload
```

After step 8, turn the preamp off. It only works together with Snapserver:

```bash
sudo rm -rf /run/systemd/system/camilladsp-preamp.service.d
sudo systemctl daemon-reload
sudo systemctl disable --now camilladsp-preamp.service
```
:::

::: warning If the install in step 8 hangs anyway
If the output stops after the `Created symlink ... camilladsp-preamp.service` line, open a second SSH session and run:

```bash
sudo systemctl stop camilladsp-preamp.service
```

The install then finishes. On a server, fix the Snapserver config as above and start the service again with `sudo systemctl restart camilladsp-preamp.service`. On a client, leave it stopped and disable it with `sudo systemctl disable camilladsp-preamp.service`.
:::

## 8 · Install the Hardware API package

This looks up the latest release on GitHub, then downloads and installs it:

```bash
TAG=$(curl -fsSL https://api.github.com/repos/byrdsandbytes/beatnik-hardware-api/releases/latest \
  | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
echo "Installing Hardware API ${TAG}"
wget -O /tmp/beatnik-hardware-api.deb \
  "https://github.com/byrdsandbytes/beatnik-hardware-api/releases/download/${TAG}/beatnik-hardware-api_${TAG#v}_all.deb"
sudo apt-get install -y --reinstall --allow-downgrades /tmp/beatnik-hardware-api.deb
rm /tmp/beatnik-hardware-api.deb
```

If the `echo` line prints no version, the GitHub lookup failed. Check the internet connection and run the block again.

`--reinstall` and `--allow-downgrades` make sure you end up on the release version with all its files in place. This matters if the package was already installed, at the same version or as a newer test build.

The package installs, enables and starts `beatnik-hardware.service` and `camilladsp.service`.

If CamillaDSP isn't at `/usr/local/bin/camilladsp` yet (`ls /usr/local/bin/camilladsp`), install it:

```bash
wget -q https://github.com/HEnquist/camilladsp/releases/download/v2.0.3/camilladsp-linux-aarch64.tar.gz -P /tmp
sudo tar -xzf /tmp/camilladsp-linux-aarch64.tar.gz -C /usr/local/bin/
rm /tmp/camilladsp-linux-aarch64.tar.gz
sudo systemctl restart camilladsp.service
```

## 9 · Install the Bleno package

Install Bleno on every device, even if 0.6 didn't have it. Besides Bluetooth setup and control, it drives the RGB button.

```bash
TAG=$(curl -fsSL https://api.github.com/repos/byrdsandbytes/beatnik-bleno/releases/latest \
  | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
echo "Installing Bleno ${TAG}"
wget -O /tmp/beatnik-bleno.deb \
  "https://github.com/byrdsandbytes/beatnik-bleno/releases/download/${TAG}/beatnik-bleno_${TAG#v}_arm64.deb"
sudo apt-get install -y --reinstall --allow-downgrades /tmp/beatnik-bleno.deb
rm /tmp/beatnik-bleno.deb
```

The package enables and starts `beatnik-bleno.service` and adds LED settings to `/boot/firmware/config.txt`. These take effect after the reboot in step 11.

## 10 · Update the Beatnik Controller

If the device has a `~/beatnik-controller` folder, pull the latest controller:

```bash
cd ~/beatnik-controller
git pull
docker compose pull
docker compose up -d
```

## 11 · Reboot

```bash
sudo reboot
```

## 12 · Check that everything runs

SSH back in and check the services:

```bash
systemctl status beatnik-hardware.service camilladsp.service --no-pager
systemctl status beatnik-bleno.service --no-pager
curl http://localhost:3000/api/hardware/status
```

All three services should be `active (running)` and the `curl` call should return JSON. Then confirm `apt` now manages the components:

```bash
dpkg -l | grep beatnik
```

Finally, play something over AirPlay or Spotify and open the Beatnik Controller to confirm the device shows up with its soundcard.

## Restore your CamillaDSP config (optional)

The Hardware API now manages the CamillaDSP config and picks the playback device for your soundcard. Use the [Camilla DSP guide](../../usage/guide-camilladsp.md) to set up your EQ again in the app. That's the safest route.

If you prefer to restore your 0.6 file directly, copy it over the new config and restart CamillaDSP:

```bash
sudo cp /var/lib/beatnik-hardware-api/camilladsp/configs/client_config.yml \
        /var/lib/beatnik-hardware-api/camilladsp/configs/client_config.yml.0-8-default
sudo cp ~/client_config.yml.0-6-backup \
        /var/lib/beatnik-hardware-api/camilladsp/configs/client_config.yml
sudo systemctl restart camilladsp.service
```

If audio stops after this, the old file probably points at the wrong playback device. Put the `.0-8-default` file back and restart CamillaDSP again.

## Future updates

From 0.8 on, you can update the Hardware API and Bleno by running the blocks from steps 8 and 9 again. They always fetch the latest release. See the package update guides for details:

- [Hardware API: Updating](https://github.com/byrdsandbytes/beatnik-hardware-api/blob/master/UPDATING_DEB.md)
- [Bleno: Updating](https://github.com/byrdsandbytes/beatnik-bleno/blob/master/UPDATE_DEB.md)
