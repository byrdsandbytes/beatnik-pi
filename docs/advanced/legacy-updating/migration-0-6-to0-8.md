# Updating from Beatnik 0.6 to 0.8

Beatnik 0.6 installed its own services from Git checkouts in your home folder. Beatnik 0.8 ships the Hardware API and the Bleno service as Debian packages that live in `/opt` and are managed by `apt`. The in-app updater can't make this switch for you, so you do it once by hand over SSH.

This guide removes the old checkouts and their systemd services, then installs the 0.8 packages. Your Snapcast, AirPlay and Spotify setup stays as it is.

::: tip Run this on every Beatnik device
Repeat the steps on your server **and** on every client Pi. Each device has its own Hardware API.
:::

## What changes

| Component | 0.6 | 0.8 |
|-----------|-----|-----|
| Hardware API | `~/beatnik-hardware-api` (installed with `setup.sh`) | `beatnik-hardware-api` package in `/opt/beatnik-hardware-api` |
| Bleno (Bluetooth setup) | `~/beatnik-bleno` (installed with `setup.sh`) | `beatnik-bleno` package in `/opt/beatnik-bleno` |
| CamillaDSP config | `~/camilladsp` | Comes with the Hardware API package, stored in `/var/lib/beatnik-hardware-api/camilladsp` |
| CamillaDSP executable | `/usr/local/bin/camilladsp` | Unchanged |
| Beatnik Controller | `~/beatnik-controller` (Docker) | Unchanged, server only |

The service names (`beatnik-hardware.service`, `beatnik-bleno.service`, `camilladsp.service`) stay the same. The packages install their own unit files in place of the old ones.

## Before you start

- SSH into the device, e.g. `ssh beatnik@beatnik-server.local`.
- Make sure the device has internet access.
- Check that you're on a 64-bit OS. The Bleno package only exists for `arm64`:

  ```bash
  dpkg --print-architecture   # must print arm64
  ```

## 1 · Check which old components are installed

```bash
ls -d ~/beatnik-hardware-api ~/beatnik-bleno ~/camilladsp ~/beatnik-controller 2>/dev/null
systemctl list-unit-files 'beatnik-*' 'camilladsp*'
```

Client Pis usually have no `beatnik-controller` folder, and `beatnik-bleno` is only present if you installed it. Skip the steps for anything that isn't there.

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

The 0.6 scripts wrote their unit files directly to `/etc/systemd/system`, pointing at your home folder. Delete them so nothing still points at the old checkouts:

```bash
sudo rm -f /etc/systemd/system/beatnik-hardware.service \
           /etc/systemd/system/beatnik-bleno.service \
           /etc/systemd/system/camilladsp.service
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

## 7 · Install the Hardware API package

Look up the latest version on the [Hardware API releases page](https://github.com/byrdsandbytes/beatnik-hardware-api/releases/latest) and set it below:

```bash
VERSION=X.Y.Z   # latest Hardware API version, without the leading "v"
cd /tmp
wget https://github.com/byrdsandbytes/beatnik-hardware-api/releases/download/v${VERSION}/beatnik-hardware-api_${VERSION}_all.deb
sudo apt-get install -y ./beatnik-hardware-api_${VERSION}_all.deb
rm beatnik-hardware-api_${VERSION}_all.deb
```

The package installs, enables and starts `beatnik-hardware.service` and `camilladsp.service`.

If CamillaDSP isn't at `/usr/local/bin/camilladsp` yet (`ls /usr/local/bin/camilladsp`), install it:

```bash
wget -q https://github.com/HEnquist/camilladsp/releases/download/v2.0.3/camilladsp-linux-aarch64.tar.gz -P /tmp
sudo tar -xzf /tmp/camilladsp-linux-aarch64.tar.gz -C /usr/local/bin/
rm /tmp/camilladsp-linux-aarch64.tar.gz
sudo systemctl restart camilladsp.service
```

## 8 · Install the Bleno package (optional)

Only needed if you want to set up and control the device over Bluetooth. Look up the latest version on the [Bleno releases page](https://github.com/byrdsandbytes/beatnik-bleno/releases/latest):

```bash
VERSION=X.Y.Z   # latest Bleno version, without the leading "v"
cd /tmp
wget https://github.com/byrdsandbytes/beatnik-bleno/releases/download/v${VERSION}/beatnik-bleno_${VERSION}_arm64.deb
sudo apt-get install -y ./beatnik-bleno_${VERSION}_arm64.deb
rm beatnik-bleno_${VERSION}_arm64.deb
```

The package enables and starts `beatnik-bleno.service` and adds LED settings to `/boot/firmware/config.txt`. These take effect after the reboot in step 10.

## 9 · Update the Beatnik Controller (server only)

On the server, pull the latest controller:

```bash
cd ~/beatnik-controller
git pull
docker compose pull
docker compose up -d
```

## 10 · Reboot

```bash
sudo reboot
```

## 11 · Check that everything runs

SSH back in and check the services:

```bash
systemctl status beatnik-hardware.service camilladsp.service --no-pager
systemctl status beatnik-bleno.service --no-pager   # if installed
curl http://localhost:3000/api/hardware/status
```

Both should be `active (running)` and the `curl` call should return JSON. Then confirm `apt` now manages the components:

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

From 0.8 on, update the Hardware API and Bleno by downloading the newer `.deb` and installing it with `sudo apt-get install ./<package>.deb`, the same way as in steps 7 and 8. See the package update guides for details:

- [Hardware API: Updating](https://github.com/byrdsandbytes/beatnik-hardware-api/blob/master/UPDATING_DEB.md)
- [Bleno: Updating](https://github.com/byrdsandbytes/beatnik-bleno/blob/master/UPDATE_DEB.md)
