

## Recommended Computing Resources

### Beatnik Pi Server
The server handles stream processing (Snapserver, Shairport-Sync, Librespot), manages WebSocket connections, hosts a Docker container and serves an Angular web app, requiring more resources. Like all endpoints, it runs CamillaDSP for DSP processing and acts as the primary master room client.

* **Absolute Minimum:** Raspberry Pi 3A+ (4 Cores CPU, 512MB RAM). However, this is explicitly *not recommended* due to potential memory constraints under load.
* **Better Choice:** Raspberry Pi 3B+ (4 Cores CPU, 1GB RAM).
* **Recommended / "Sweet Spot":** **Raspberry Pi 4B with 2-4GB RAM** (4 Cores @ 1.5/1.8 GHz).
* **Overkill:** Anything over 8GB RAM is unnecessary unless you plan to host numerous other memory-intensive services on the same device.
* **Storage:** A high-quality 32GB Micro SD Card (Raspberry Pi Foundation or SanDisk Extreme recommended).

### Beatnik Pi Client
Clients receive the audio streams, pass them through CamillaDSP for local processing, and play them back. This requires less CPU and RAM than the server workload.

* **Minimum Requirement:** Raspberry Pi Zero 2 W (4 Cores @ 1.0 GHz, 512MB RAM). 
* **Recommended / Preferred:** **Raspberry Pi 3A+** (4 Cores @ 1.4 GHz, 512MB RAM), for better performance handling the connection and basic audio tasks.
* **Storage:** A high-quality 32GB Micro SD Card (Raspberry Pi Foundation or SanDisk Extreme recommended).


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

> **Important Caveats:**
> * **Raspberry Pi 4 CPU:** Earlier revisions of the Pi 4 shipped locked at 1.5 GHz. Newer board revisions and recent firmware updates officially push this to 1.8 GHz.
> ** **Raspberry Pi 3 B+ Ethernet:** While it features a "Gigabit" Ethernet port, it is bottlenecked internally by the board's USB 2.0 bus. Its actual maximum throughput is around 300 Mbps.
