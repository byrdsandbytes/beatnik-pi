# Beatnik Pi - Docker Edition

This guide explains how to run the Beatnik Pi Snapcast server using Docker and Docker Compose. This method is recommended for a clean, portable, and easy-to-manage setup.

## Overview

This Docker Compose setup orchestrates all the necessary services to create a powerful, multi-room audio server:

-   **Snapserver**: The core Snapcast server that receives and distributes audio.
-   **Shairport-Sync**: Provides AirPlay 1 & 2 support.
-   **Librespot**: Provides Spotify Connect support.
-   **Beatnik Controller**: The web interface for controlling clients and streams.

The services communicate using shared named pipes for audio, ensuring high performance and low latency.

## Prerequisites

-   A host machine (like a Raspberry Pi 4/5 or any Linux server) with **Docker** and **Docker Compose** installed.
-   Basic familiarity with the command line.

### Installing Docker & Docker Compose

If you don't have them installed, you can use the official convenience script:

Install Docker via Script

```bash
# Install Docker

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to the docker group to run commands without sudo
sudo usermod -aG docker ${USER}
newgrp docker # Apply the new group membership
```

## 1. Configuration

Before launching, you might want to review the configuration.

### `docker-compose.yml`

-   **Stream Names**: You can change the `name` argument for `shairport-sync` and `librespot` to customize the device names that appear for AirPlay and Spotify Connect.
-   **Controller Image**: The `beatnik-controller` service uses a public image. If you have a custom build, update the `image` tag.

### `snapserver.conf`

-   **Stream Names**: The `name` parameter in the `[stream]` sections determines how the streams are displayed in Snapcast clients (e.g., Snapweb).
-   **Local Playback (Alsa)**: The `[alsa]` section is configured to play audio on the host machine's default sound device, making the server itself a client.
    -   To use a specific soundcard, run `aplay -l` on the host machine to list available devices.
    -   Then, update `soundcard = default` to `soundcard = hw:X,Y`, where `X` and `Y` are the card and device numbers. For example: `soundcard = hw:1,0`.

## 2. Running the System

With the configuration in place, starting the entire stack is as simple as running one command from your project directory:

```bash
# Start all services in the background
docker compose up -d
```

The first time you run this, Docker will download the necessary images, which might take a few minutes.

## 3. Managing the Services

Here are the essential commands for managing your Dockerized Beatnik Pi server:

-   **Check Logs**: To see the real-time logs from all services, use:
    ```bash
    docker compose logs -f
    ```
    To view logs for a specific service (e.g., `snapserver`):
    ```bash
    docker compose logs -f snapserver
    ```

-   **Stop Services**: To stop all running services:
    ```bash
    docker compose down
    ```

-   **Restart Services**:
    ```bash
    docker compose restart
    ```

## 4. Accessing the System

Once the services are running, you can access them as follows:

-   **AirPlay**: On your Apple device, look for a new AirPlay device named "Beatnik-Airplay" (or whatever you configured).
-   **Spotify Connect**: In the Spotify app, look for a new device named "Beatnik-Spotify".
-   **Beatnik Controller**: Open a web browser and navigate to `http://<your-pi-ip-address>:8181`.
-   **Classic Snapweb UI**: For a simpler view, navigate to `http://<your-pi-ip-address>:1780`.

## 5. Connecting Snapcast Clients

Any Snapcast client on your network can connect to this server. When configuring your clients (e.g., in `/etc/snapclient.conf` or through the client's settings), use the IP address of the host machine running Docker as the `host`.

Example `snapclient.conf`:
```ini
[snapclient]
host = <your-pi-ip-address>
```

Happy listening! 🎶
