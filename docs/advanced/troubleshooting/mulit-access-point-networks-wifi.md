# Wi-Fi Crashes on Multi-Access-Point Networks

This guide helps you diagnose and resolve Wi-Fi crashes on Beatnik Pi devices when connected to high-density & high complexity networks with multiple access points, that are in reach simultaneously.

**NOTE:** This is only relevant to prove that the issue is caused by high-density multi-access-point Wi-Fi environments and not by other factors like hardware faults or software bugs unrelated to networking. Usually service providers configure this correctly but you may need to help them getting the settings right.
Therefore it is important to first confirm that the Wi-Fi crashes are indeed caused by the network environment so you can apply the appropriate network-level fixes rather than chasing unrelated hardware or software issues.

If the Raspberry Pi's Wi-Fi controller crashes in a large or enterprise network (the `brcmfmac` driver logs an `mmc1` error with `-5` I/O error in `dmesg`), you need to monitor live traffic and network state right before the error occurs.

This guide describes the debugging methodology for Beatnik Pi in a large environment, ordered by the most likely culprits.

---

## Phase 1: Live Log Analysis (Finding the Trigger)

Before applying fixes, run these diagnostics via SSH to catch the exact event that causes the `brcmfmac` driver to crash.

### 1. Monitor for Multicast/Broadcast Flooding

In a large network without proper filtering, every multi-room audio packet is sent to every device. The Pi's Wi-Fi buffer fills up and crashes the chip.

`tcpdump` is not installed on Beatnik Pi by default. Install it first:

```bash
sudo apt update && sudo apt install -y tcpdump
```

Then run a packet capture on the Pi looking for multicast/broadcast spam:

```bash
sudo tcpdump -i wlan0 multicast or broadcast -n
```

**Verification:** If your terminal instantly becomes an unreadable blur of scrolling IP addresses, the network is flooding the Pi. A healthy network only shows a few packets per second (like mDNS discovery or ARP requests). Press `Ctrl+C` to stop.

### 2. Track AP Roaming Thrashing (802.11r/k/v)

If the Pi can "hear" multiple access points, the enterprise network may constantly try to force it to roam, which the Broadcom driver cannot handle gracefully.

Filter your network logs for roaming and authentication events:

```bash
sudo journalctl -u NetworkManager -u wpa_supplicant -f | grep -iE 'roam|bssid|auth|assoc'
```

**Verification:** Leave this running. If you see the Pi constantly authenticating, disassociating, or changing BSSIDs right before the audio drops and the `mmc1` error appears in `dmesg`, Fast Roaming is your root cause.

### 3. Verify Hardware Power under Audio Load

If the network logs are quiet, the amplifier or DAC HAT may be drawing peak power during heavy bass or volume spikes, momentarily starving the Wi-Fi chip.

```bash
watch -n 1 vcgencmd get_throttled
```

**Verification:** Keep this terminal open while playing audio at the volume where it typically fails. If the output ever changes from `0x0` to `0x50000`, the Pi is experiencing a hard voltage drop.

---

## Phase 2: Troubleshooting & Resolution (Ordered by Likelihood)

Apply the fix matching your diagnostic results. In large multi-AP installations, Methods 1 and 2 solve most Raspberry Pi Wi-Fi lockups.

### 1. Enable IGMP Snooping & Multicast Enhancement (Highly Likely)

If `tcpdump` showed a massive flood of traffic, the core network switch and access points are treating your audio streams as broadcast data.

1. Log into your central network controller (e.g., UniFi Network Application, Omada, Cisco).
2. Navigate to your **Networks/VLANs** settings and enable **IGMP Snooping**.
3. Navigate to your **Wi-Fi/SSID** settings and enable **Multicast Enhancement (IGMPv3)**.

**Verification:** Re-run the `tcpdump` command on the Pi. The wall of scrolling text should be gone, replaced by a slow trickle of background packets.

### 2. Lock the BSSID to Prevent Roaming (Highly Likely)

If `journalctl` showed the Pi bouncing between access points, force it to ignore enterprise roaming commands.

1. Scan for the strongest access point MAC address:

   ```bash
   nmcli -f BSSID,SIGNAL,SSID dev wifi list
   ```

2. Lock your Wi-Fi profile to the strongest BSSID (replace with your SSID and the chosen BSSID):

   ```bash
   sudo nmcli connection modify "Your_SSID" 802-11-wireless.bssid XX:XX:XX:XX:XX:XX
   ```

3. Apply the changes:

   ```bash
   sudo systemctl restart NetworkManager
   ```

**Verification:** Run `iwconfig wlan0`. The `Access Point:` field should permanently display the MAC address you targeted, regardless of network conditions.

### 3. Disable Wi-Fi Power Management (Moderately Likely)

Even when locked to a single AP, NetworkManager on Debian can aggressively put the Broadcom chip to sleep between audio tracks.

1. Disable power saving on your Wi-Fi profile with `nmcli` (`2` = disabled):

   ```bash
   sudo nmcli connection modify "Your_SSID" 802-11-wireless.powersave 2
   ```

2. Reconnect to apply the change:

   ```bash
   sudo nmcli connection down "Your_SSID" && sudo nmcli connection up "Your_SSID"
   ```

   If you are connected over SSH via Wi-Fi, the session will drop. Reboot the Pi instead.

**Verification:** Run `iw dev wlan0 get power_save`. It must return `Power save: off`.

### 4. Upgrade the Power Supply (Less Likely in Enterprise, but Possible)

If `vcgencmd` flagged a voltage drop, no software configuration will fix the hardware disconnect.

1. Use an official 5V/3A (15W) or higher power supply.
2. If the Pi is powering a heavy HiFiBerry or similar audio HAT, power the HAT directly if it has its own barrel jack, rather than passing all power through the Pi's USB-C port.

**Verification:** After replacing the supply, `vcgencmd get_throttled` should stay at `0x0` even at maximum speaker volume.
