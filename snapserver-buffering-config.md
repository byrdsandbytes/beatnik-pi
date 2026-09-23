# Snapserver & Snapclient Buffering Configuration Guide

When streaming multi-room audio over Wi-Fi, tuning your buffer and latency parameters in **Snapserver** and **Snapclient** is the most effective way to eliminate audio dropouts, clicks, and synchronization drift without degrading audio quality.

This guide explains how Snapcast handles buffering from end to end, the key configuration options, and practical tuning presets for various network conditions.

---

## 1. How Buffering Works in Snapcast

Snapcast synchronizes audio by timestamping chunks of audio at the server and scheduling them to be played in the future on each client.

```
[Audio Source] 
       │
       ▼
[Snapserver] ──(reads chunk_ms)──> [Encoder (flac/pcm/opus)] ──(server buffer: 1000ms target playout)──> [Network]
                                                                                                              │
                                                                                                              ▼
[ALSA Hardware Playback] <──(client buffer: cushion)── <──(Snapclient Buffer & Time Sync Engine) <────────────┘
```

1. **`chunk_ms` (Server)**: How many milliseconds of raw audio the server reads from the source at a time before compressing and transmitting.
2. **`buffer` (Server)**: The overall end-to-end target latency (in ms) from the moment the server captures a sample until the client plays it. This is how far ahead into the future audio is scheduled.
3. **`buffer` (Client)**: A local client-side buffer (cushion) that protects against local Wi-Fi jitter, scheduling delays, and ALSA ring buffer underruns.

---

## 2. Snapserver Buffering Options (`/etc/snapserver.conf`)

Edit the server configuration file:

```bash
sudo nano /etc/snapserver.conf
```

All stream-level buffering settings reside under the `[stream]` section.

### 2.1 End-to-End Latency (`buffer`)

```ini
[stream]
# End-to-end latency in milliseconds (default: 1000)
buffer = 1000
```

- **Default:** `1000` (1 second).
- **What it does:** Sets the total time between when audio is read on the server and when it exits the speakers on client Pis.
- **When to increase (e.g., `1500` - `2000`):**
  - High-traffic Wi-Fi networks or multiple hops / repeaters.
  - Clients frequently reporting `Late chunk` errors in `journalctl -u snapclient -f`.
  - AirPlay 2 or Spotify multi-room groups with many wireless clients.
- **When to decrease (e.g., `400` - `600`):**
  - Wired Gigabit Ethernet setups where you want near-instant response when skipping tracks, pausing, or watching video/dialogue.

---

### 2.2 Source Chunk Size (`chunk_ms`)

```ini
[stream]
# Source stream read chunk size in milliseconds (default: 20)
chunk_ms = 20
```

- **Default:** `20` ms.
- **What it does:** Determines the duration of each audio package sent over the network.
- **Codec interaction:**
  - **FLAC (default):** Typically requires ~26 ms blocks. Setting `chunk_ms = 26` or leaving at `20` works well.
  - **PCM / Opus:** Can use smaller chunks (`10` - `20` ms) for slightly reduced overhead.
- **Tuning rule:** Higher values (e.g., `26`–`30`) result in fewer network packets per second and lower CPU overhead on Raspberry Pi Zero clients, but increase packet transmission intervals.

---

### 2.3 Per-Source Chunk Overrides

You can also specify `chunk_ms` per stream directly inside the `source` URI query string:

```ini
[stream]
# Example: Custom chunk size for AirPlay 2 and Spotify
source = airplay:///shairport-sync?name=AirPlay2&devicename=Beatnik-Airplay2&port=7000&chunk_ms=26
source = spotify:///librespot?name=Spotify&devicename=Beatnik-Spotify&chunk_ms=26
```

---

### 2.4 Worker Threads (`[server]` section)

If your server runs on a Raspberry Pi 4 or Pi 5 and encodes multiple streams simultaneously, ensure worker threads are properly allocated:

```ini
[server]
# Threads: -1 (auto-detect cores), or explicitly set to 4 on Pi 4/5
threads = -1
```

*Avoid setting `threads = 0`, as it forces all encoding onto a single thread and can cause audio drops during peak processing.*

---

## 3. Snapclient Buffering Options (`/etc/snapclient.conf`)

Edit the client configuration file on each speaker node:

```bash
sudo nano /etc/snapclient.conf
```

```ini
[snapclient]
host         = beatnik-server.local
sound_device = hw:0,0
# Client buffer in milliseconds (default: unset / ALSA native)
buffer       = 120
```

### Understanding the Client Buffer:
- The client `buffer` (measured in ms) is an internal safety cushion that delays output by an additional short window, allowing the client's ALSA driver to maintain a steady stream even if a packet arrives a few milliseconds late due to Wi-Fi jitter.
- **Recommended settings:**
  - **Ethernet (LAN):** `0` or `50` ms
  - **Clean Wi-Fi (5 GHz):** `80` - `100` ms
  - **Noisy Wi-Fi (2.4 GHz / Pi Zero):** `120` - `200` ms

---

## 4. Recommended Profiles

Choose the profile that matches your environment:

### Profile A: Standard Home Wi-Fi (Recommended Default)
*Balanced stability and responsiveness.*

- **`/etc/snapserver.conf`:**
  ```ini
  [stream]
  codec = flac
  chunk_ms = 20
  buffer = 1000
  ```
- **`/etc/snapclient.conf`:**
  ```ini
  [snapclient]
  buffer = 120
  ```

---

### Profile B: Challenged / High-Jitter Wi-Fi (Maximum Reliability)
*For setups experiencing periodic dropouts, multiple mesh nodes, or distant clients.*

- **`/etc/snapserver.conf`:**
  ```ini
  [stream]
  codec = flac
  chunk_ms = 26
  buffer = 1500
  ```
- **`/etc/snapclient.conf`:**
  ```ini
  [snapclient]
  buffer = 200
  ```

---

### Profile C: Low Latency (Wired / Dedicated 5 GHz Network)
*Faster track skipping and pause response.*

- **`/etc/snapserver.conf`:**
  ```ini
  [stream]
  codec = flac
  chunk_ms = 20
  buffer = 500
  ```
- **`/etc/snapclient.conf`:**
  ```ini
  [snapclient]
  buffer = 50
  ```

---

## 5. Applying Changes and Verifying

### 1. Restart Services

After editing configuration files, restart the services to apply changes:

**On the Server:**
```bash
sudo systemctl restart snapserver
```

**On the Client:**
```bash
sudo systemctl restart snapclient
```

### 2. Verify with Live Logs

Monitor the logs to confirm smooth streaming:

```bash
# Check client sync and buffer status
journalctl -u snapclient -f
```

**What to look for:**
- `Connected to beatnik-server.local:1704`
- `metadata: {"bufferMs":1000,"codec":"flac",...}`
- Stable time sync messages without frequent `Late chunk` or `Buffer underrun` alerts.

---

## Related Documentation
- [network-debugging.md](network-debugging.md) - Wi-Fi signal inspection, `nmcli` diagnostics, and power-saving fixes.
- [network-reqiurements.md](network-reqiurements.md) - Router, AP, and port allowlist requirements.
- [sample-snapserver.conf](docs/sample-configs/sample-snapserver.conf) - Full sample configuration file.