# Bleno Service (BLE WiFi Provisioning)

Source: [byrdsandbytes/beatnik-bleno](https://github.com/byrdsandbytes/beatnik-bleno)

A Bluetooth Low Energy (BLE) WiFi provisioning service for Raspberry Pi, built with TypeScript on top of [@abandonware/bleno](https://github.com/abandonware/bleno).

## Features

- BLE WiFi provisioning: scan networks, submit SSID/password, trigger connection, read status via BLE characteristics
- Status notifications over BLE
- Runs on Linux (Raspberry Pi) and macOS (for development/testing)

## Prerequisites

- Raspberry Pi (or other Linux device) with a Bluetooth 4.0+ adapter
- Node.js v22
- `bluetooth`, `bluez`, `network-manager` system packages

## Installation

For Raspberry Pi deployment (production release or from source), see [INSTALL_DEB.md](https://github.com/byrdsandbytes/beatnik-bleno/blob/master/INSTALL_DEB.md) for the `.deb` package (recommended; update with [UPDATE_DEB.md](https://github.com/byrdsandbytes/beatnik-bleno/blob/master/UPDATE_DEB.md), remove with [UNINSTALL_DEB.md](https://github.com/byrdsandbytes/beatnik-bleno/blob/master/UNINSTALL_DEB.md)) or [INSTALL.md](https://github.com/byrdsandbytes/beatnik-bleno/blob/master/INSTALL.md) for the script/source methods.

For local development:

```bash
git clone https://github.com/byrdsandbytes/beatnik-bleno.git
cd beatnik-bleno
npm install
npm run build
```

Bleno requires raw socket access. Either run with `sudo` or grant the capability once:

```bash
sudo setcap cap_net_raw+eip $(eval readlink -f `which node`)
```

## Usage

```bash
npm start       # build + run compiled JS
npm run dev     # run via ts-node without building
npm run watch   # auto-recompile on changes
```

Once running, the device advertises as `beatnik` with a Nordic UART-style service.

## API / Characteristics

| Characteristic | UUID | Properties | Description |
| -------------- | ---- | ---------- | ----------- |
| SSID | `6E400002-B5A3-F393-E0A9-E50E24DCCA9E` | Write | WiFi network name (UTF-8 string) |
| Password | `6E400003-B5A3-F393-E0A9-E50E24DCCA9E` | Write | WiFi password (UTF-8 string) |
| Connect | `6E400004-B5A3-F393-E0A9-E50E24DCCA9E` | Write | Write `1` to trigger connection |
| Status | `6E400005-B5A3-F393-E0A9-E50E24DCCA9E` | Read, Notify | JSON status object |

Status response:

```json
{
  "connected": true,
  "ssid": "MyWiFiNetwork",
  "ip": "192.168.1.100",
  "message": "Connected successfully"
}
```

## Project Structure

```
beatnik-bleno/
├── src/
│   ├── main.ts                      # Application bootstrap
│   ├── config/app.config.ts         # BLE UUIDs, device name, WiFi interface
│   ├── models/                      # TypeScript interfaces and enums
│   ├── services/                    # WiFi manager, GPIO, state services
│   └── characteristics/             # BLE characteristic implementations
├── dist/                            # Compiled JavaScript output
└── package.json
```

## Configuration

Edit `src/config/app.config.ts` to change the BLE device name, UUIDs, or WiFi interface (default `wlan0`).

## Troubleshooting

**Bluetooth not working:**

```bash
hciconfig
sudo hciconfig hci0 down && sudo hciconfig hci0 up
```

**Permission denied:** run with `sudo` or set the capability shown under Installation.

**WiFi interface blocked (RF-kill):**

```bash
ip link show wlan0
sudo rfkill unblock wifi
sudo ip link set wlan0 up
```

**WiFi scan returns no networks:** the WiFi country code is likely unset. Run `sudo raspi-config` -> Localisation Options -> WLAN Country, select your country, and reboot.

**Service logs:**

```bash
sudo journalctl -u beatnik-bleno.service -f
```

## Security Considerations

- Credentials are transmitted in plain text over BLE by default; use BLE pairing/encryption for production
- Add authentication and rate limiting before deploying beyond trusted environments
- Limit the provisioning time window

## License

AGPLv3

## Contributing

Issues and pull requests are welcome.
