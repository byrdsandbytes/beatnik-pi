

## Recommended Computing Resources

TLDR; Server = 1GB -> Currently pi 3B+, Client -> 3A+ because 5 GHz Wi-Fi is strongly preferred over 2.4 GHz.
(Updated 19.04.2026)

### Beatnik Pi Server
The server handles stream processing (Snapserver, Shairport-Sync, Librespot), manages WebSocket connections, hosts a Docker container that serves the beatnik controller Angular web app, requiring more resources. Like all endpoints, it runs CamillaDSP for DSP processing for your amp or DAC. Having a bit headroom for future features is recommended.

* **Absolute Minimum:** Raspberry Pi 3A+ (4 Cores CPU, 512MB RAM). However, this is explicitly *not recommended* due to potential memory constraints under load. (Things like Signal Visuals in the app may be laggy)
* **Better Choice:** Raspberry Pi 3B+ (4 Cores CPU, 1GB RAM).
* **Recommended / "Sweet Spot":** **Raspberry Pi 4B with 2-4GB RAM** (4 Cores @ 1.5/1.8 GHz).
* **Overkill:** Anything over 8GB RAM is unnecessary unless you plan to host numerous other memory-intensive services on the same device.
* **Storage:** A high-quality 32GB Micro SD Card (Raspberry Pi Foundation (currently overpriced) recommended). A shitty SD Card will cause headaches.
* **Network:** 5 GHz Wi-Fi is strongly preferred (or Ethernet) for stability and bandwidth.

### Beatnik Pi Client
Clients receive the audio streams, pass them through CamillaDSP for local processing, and play them back. This requires less CPU and RAM than the server workload.

* **Minimum Requirement:** Raspberry Pi Zero 2 W (4 Cores @ 1.0 GHz, 512MB RAM). 
* **Recommended / Preferred:** **Raspberry Pi 3A+** (4 Cores @ 1.4 GHz, 512MB RAM), for better performance handling the connection and basic audio tasks.
* **Storage:** A high-quality 32GB Micro SD Card (Raspberry Pi Foundation or SanDisk Extreme recommended).
* **Network:** 5 GHz Wi-Fi is preferred for reliable stream reception.


### **Raspberry Pi Models Overview**

| Model | Form Factor | CPU (Cores & Speed) | RAM | Wi-Fi Bands | Ethernet |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Raspberry Pi 5** | B | 4 Cores @ 2.4 GHz | 1GB, 2GB, 3GB, 4GB, 8GB, 16GB | 2.4 GHz & 5 GHz | Gigabit |
| **Raspberry Pi 4 (B)** | B | 4 Cores @ 1.5 / 1.8 GHz* | 1GB, 2GB, 4GB, 8GB | 2.4 GHz & 5 GHz | Gigabit |
| **Raspberry Pi 3 (B+)** | B | 4 Cores @ 1.4 GHz | 1GB | 2.4 GHz & 5 GHz | Gigabit (Max ~300 Mbps)** |
| **Raspberry Pi 3 (A+)** | A | 4 Cores @ 1.4 GHz | 512MB | 2.4 GHz & 5 GHz | None |
| **Raspberry Pi 3 (B)** | B | 4 Cores @ 1.2 GHz | 1GB | 2.4 GHz Only | 10/100 Mbps |
| **Raspberry Pi 2 (B)** | B | 4 Cores @ 0.9 GHz | 1GB | None | 10/100 Mbps |
| **Raspberry Pi 1 (B / B+)** | B | 1 Core @ 0.7 GHz | 512MB | None | 10/100 Mbps |
| **Raspberry Pi 1 (A / A+)** | A | 1 Core @ 0.7 GHz | 256MB / 512MB | None | None |
| **Pi Zero 2 W** | Zero | 4 Cores @ 1.0 GHz | 512MB | 2.4 GHz Only | None |
| **Pi Zero W / WH** | Zero | 1 Core @ 1.0 GHz | 512MB | 2.4 GHz Only | None |
| **Pi Zero** | Zero | 1 Core @ 1.0 GHz | 512MB | None | None |


