# Settings & Help

## Settings

::: warning 📸 Screenshot needed
Settings screen (Username, Server Url, Scan for devices on startup).
:::

Open **Menu > Settings**.

| Setting | Description |
|---------|-------------|
| **Username** | Personalises the dashboard ("Alex's Home"). |
| **Server Url** | Host name or IP address of your Snapcast server. |
| **Scan for devices on startup** | Automatically search for devices when the app starts. |
| **Connect to Server** | Reconnects to the entered server URL. |

---

## Demo mode

::: warning 📸 Screenshot needed
Menu with the Enable Demo Mode entry.
:::

**Menu > Enable Demo Mode** loads a mock server state with sample devices and streams so you can explore the app without any hardware.

---

## Web vs. mobile app

| Feature | Web | iOS / Android |
|---------|:---:|:-------------:|
| Dashboard, devices, streams | Yes | Yes |
| Volume and stream presets | Yes | Yes |
| Camilla DSP, updates, server status | Yes | Yes |
| Network scanner (mDNS) | No | Yes |
| Add device via Bluetooth/Wi-Fi setup | No | Yes |
| Haptic feedback | No | Yes |

---

## Troubleshooting

| Problem | What to try |
|---------|-------------|
| Dashboard shows "Set Up Your Beatnik" | The server is unreachable. Check **Settings > Server Url**, or use the network scanner. |
| Dashboard shows "Offline" | The last server response is older than a few minutes. Open [Server status](./guide-maintenance.md#server-status-and-maintenance) and tap **Attempt to Connect**, or restart the Snapserver. |
| Device not found during setup | Hold the setup button for 5 seconds until the LED pulses blue, keep Bluetooth enabled and stay close to the device. |
| Setup fails on Wi-Fi | Make sure the phone is on the same Wi-Fi network and the password is correct. |
| A client is greyed out | The client is offline. Check power and network, restart it, or use **Clean Offline Clients** to remove it permanently. |
| Camilla DSP does not connect | Open the device from the device list or scanner so a network address is known, then retry. |
| No sound after a device was added | Check the soundcard configuration in the client's **Soundcard** tab. |

For further help, see [CONTRIBUTING.md](https://github.com/byrdsandbytes/beatnik-controller/blob/master/CONTRIBUTING.md) or open an issue on [GitHub](https://github.com/byrdsandbytes/beatnik-controller/issues).
