# Network Debugging Guide for Beatnik Pi

If you experience buffering issues, audio dropouts, synchronization drift, or playback hiccups, the root cause is almost always related to local network latency, packet loss, or Wi-Fi interference. 

Because Snapcast distributes uncompressed audio in real time, it requires a steady, low-jitter stream between the server and all client nodes.

This step-by-step guide helps you locate the source of the issue, verify your signal quality, and optimize your setup.

> **Note:** For general infrastructure prerequisites and enterprise/VLAN configuration, refer to [network-reqiurements.md](network-reqiurements.md).

---

## Quick Symptom Checklist

| Symptom | Likely Cause | Primary Fix |
| --- | --- | --- |
| **Periodic audio stutter / clicks** | Wi-Fi power-save mode or channel interference | Disable Wi-Fi power saving; move to 5 GHz or cleaner channel |
| **Audio pauses or falls behind** | High jitter or weak signal (< -70 dBm) | Check `nmcli` signal strength; increase client buffer cushion |
| **Clients cannot find the server** | mDNS / Multicast blocked or Client Isolation on | Disable AP/Client Isolation; ensure mDNS (port 5353) is forwarded |
| **Sudden disconnects during playback** | DHCP lease expiry or AP roaming issues | Assign static IP / DHCP reservation; lock client to nearest BSSID |

---

## 1. SSH into the Raspberry Pi

Connect to the affected device (server or client) over SSH:

```bash
ssh beatnik@beatnik-XXX.local
```

- Replace `beatnik-XXX` with your specific device hostname (e.g., `beatnik-001.local` or the custom hostname configured during flashing). You can find this in the Beatnik Controller app or in your router's client list.
- If you configured a different username during flashing, replace `beatnik` accordingly.
- Enter your password (set during OS flashing or provided with your image).

*(Tip: If `.local` resolution fails, use the Pi's direct IP address, for example: `ssh beatnik@192.168.1.50`)*

---

## 2. Check Wi-Fi Signal Strength and Link Quality

*(Signal strength monitoring will also be integrated directly into the Beatnik Controller app in an upcoming release.)*

On Debian Bookworm / Raspberry Pi OS, **NetworkManager** manages wireless connections. Use `nmcli` to inspect the link status:

### Check Active Wi-Fi Connection

```bash
nmcli -f in-use,ssid,bssid,signal,bars,rate,chan dev wifi
```

You will see output similar to:
```
IN-USE  SSID          BSSID              SIGNAL  BARS  RATE        CHAN 
*       MyHomeWiFi    AA:BB:CC:DD:EE:FF  72      ▂▄▆_  130 Mbit/s  6    
```

### Check Detailed Radio & Signal Levels

For real-time decibel measurements (RSSI), run:

```bash
iw dev wlan0 link
```

Look for the **signal** value:
- **-30 dBm to -60 dBm (Signal > 70%):** Excellent. Ideal for low-latency multi-room audio.
- **-61 dBm to -70 dBm (Signal 50% - 70%):** Good/Fair. Adequate, but sensitive to transient interference.
- **-71 dBm or weaker (Signal < 50%):** Weak. Frequent buffer underruns, packet retransmissions, and dropouts are expected.

### Actions If Signal Is Poor:
- Move the Pi away from metal enclosures, power bricks, or behind large TV panels.
- If using an external Wi-Fi dongle or antenna, adjust orientation.
- Connect to a 5 GHz band if available nearby, or connect via Ethernet cable for the server node whenever possible.

---

## 3. Disable Wi-Fi Power Management

By default, Raspberry Pi OS enables wireless power management to conserve energy. This routinely causes the Wi-Fi chip to enter sleep states, introducing **periodic 50–200ms latency spikes**, which directly cause audio stutter.

### Check Current Power Management Status

```bash
iw dev wlan0 get power_save
```

If it reports `Power save: on`, turn it off immediately:

### Temporarily Disable Power Save

```bash
sudo iw dev wlan0 set power_save off
```

### Permanently Disable Power Save in NetworkManager

To make this persistent across reboots:

```bash
sudo nmcli connection modify "$(nmcli -g NAME connection show --active | head -n 1)" 802-11-wireless.powersave 2
```

*(Value `2` explicitly disables power saving in NetworkManager).*

---

## 4. Test Latency, Packet Loss, and Jitter

Audio streaming requires consistent packet delivery rather than raw bandwidth. Run a continuous ping test from the client to the server:

```bash
ping -c 50 beatnik-server.local
```

### Analyze the Results:
- **Packet Loss:** Must be **0.0%**. Even 1% packet loss will manifest as audible pops or dropouts.
- **Round-Trip Time (RTT):**
  - **Ideal:** Steady 2 ms – 15 ms.
  - **Problematic:** Values that jump erratically (e.g., `5ms -> 240ms -> 8ms`). High variance (jitter) causes the local buffer to starve.

---

## 5. Verify mDNS & Service Discovery

If client nodes cannot detect the server, or if AirPlay / Spotify / Web UI discovery is failing:

1. **Verify the Avahi Daemon is running on the Pi:**
   ```bash
   sudo systemctl status avahi-daemon
   ```
2. **Test hostname resolution from another machine:**
   ```bash
   ping beatnik-server.local
   ```
3. **Inspect Multicast on your Router / Access Point:**
   - **Client/AP Isolation:** Must be **DISABLED**. (If enabled, devices on Wi-Fi cannot talk to each other).
   - **mDNS / Bonjour Multicast:** Must be **ENABLED**.
   - **IGMP Snooping:** If enabled without an active IGMP querier, multicast packets may be dropped after a few minutes. Set to **DISABLED** if in doubt.

---

## 6. Inspect Snapcast Logs for Dropouts

Check the system logs in real time to see if chunks are arriving late or dropping:

### On the Snapserver:
```bash
journalctl -u snapserver -f
```

### On the Snapclient:
```bash
journalctl -u snapclient -f
```

**Common log warnings to look for:**
- `Buffer underrun`: The soundcard consumed audio faster than the network delivered it (increase buffer size or fix Wi-Fi jitter).
- `Late chunk`: Packets arrived past their scheduled playback timestamp and were discarded.
- `Diff to server: XXX ms`: Significant clock drift; indicates high network latency fluctuations or NTP sync issues.

---

## 7. Increase the Snapclient Buffer Cushion

If you have an inherently noisy Wi-Fi environment and cannot eliminate minor jitter, you can increase the client's internal playback buffer.

1. Open the Snapclient configuration:
   ```bash
   sudo nano /etc/snapclient.conf
   ```
2. Locate or add the `buffer` option under `[snapclient]`:
   ```ini
   [snapclient]
   host = beatnik-server.local
   sound_device = hw:0,0
   buffer = 150
   ```
   *(Default is usually 80–100 ms. Try 150 ms or 200 ms for Wi-Fi clients).*
3. Restart the client:
   ```bash
   sudo systemctl restart snapclient
   ```

---

## 8. Quick Diagnostic Command Cheat Sheet

| Task | Command |
| --- | --- |
| Scan visible Wi-Fi networks | `nmcli dev wifi list` |
| View active Wi-Fi link & signal | `nmcli -f in-use,ssid,bssid,signal,bars,rate,chan dev wifi` |
| View link details & RSSI (dBm) | `iw dev wlan0 link` |
| Check Wi-Fi power-save mode | `iw dev wlan0 get power_save` |
| Turn off Wi-Fi power save (now) | `sudo iw dev wlan0 set power_save off` |
| Test latency and packet loss | `ping -c 30 <server-ip-or-hostname>` |
| View live client logs | `journalctl -u snapclient -f` |
| View live server logs | `journalctl -u snapserver -f` |
| Restart Snapclient service | `sudo systemctl restart snapclient` |
| Restart Snapserver service | `sudo systemctl restart snapserver` | 




