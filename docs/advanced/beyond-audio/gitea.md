# Gitea with Cloudflare Tunnel

This guide sets up [Gitea](https://about.gitea.com/), a lightweight self-hosted Git service, on your Beatnik Pi. It then makes Gitea reachable from the internet through a [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/), so you don't need to open any ports on your router.

::: info Before you start
Read the [ground rules for this section](./index.md) first.

You'll need:
- A Beatnik Pi you can reach over SSH
- A free Cloudflare account with a domain added to it
:::

## Phase 1: Generate a Cloudflare Tunnel token

If you get the token first, you can start everything on the Pi with a single command.

1. Log in to the [Cloudflare Zero Trust dashboard](https://one.dash.cloudflare.com/).
2. In the left sidebar, go to **Networks** > **Tunnels**.
3. Click **Create a tunnel**, select **Cloudflared** and give it a name (e.g. `beatnik-gitea`). Click **Save tunnel**.
4. On the installation screen, select the **Docker** environment.
5. In the command box, find the long string right after `--token` and copy it.

::: warning
The token gives full control of the tunnel. Treat it like a password and don't commit it to a Git repository.
:::

## Phase 2: Configure the Beatnik Pi

1. **Connect via SSH** to your Beatnik Pi:

   ```bash
   ssh yourusername@your-beatnik-ip
   ```

2. **Create a dedicated directory** so the Gitea data stays separate from the Beatnik audio components:

   ```bash
   mkdir -p ~/gitea
   cd ~/gitea
   ```

3. **Create the Docker Compose file**:

   ```bash
   nano docker-compose.yml
   ```

4. **Paste the configuration below** and replace `your_copied_token_here` with your token from Cloudflare:

   ```yaml
   services:
     gitea:
       image: gitea/gitea:latest
       container_name: gitea
       environment:
         - USER_UID=1000
         - USER_GID=1000
       restart: unless-stopped
       volumes:
         - ./data:/data
         - /etc/timezone:/etc/timezone:ro
         - /etc/localtime:/etc/localtime:ro
       ports:
         - "3030:3000"   # Web UI (3000 is taken by the Beatnik Hardware API)
         - "2222:22"     # Git over SSH (22 is the Pi's own SSH)

     cloudflared:
       image: cloudflare/cloudflared:latest
       container_name: cloudflared
       restart: unless-stopped
       command: tunnel run
       environment:
         - TUNNEL_TOKEN=your_copied_token_here
   ```

   Save the file and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).

5. **Start the containers**:

   ```bash
   docker compose up -d
   ```

   Both containers start and join the same internal Docker network automatically.

## Phase 3: Route your domain

The tunnel is now running on your Pi. Next, tell Cloudflare where to send the traffic.

1. Back in the Zero Trust dashboard, your tunnel should now show as **Healthy**. Click it and select **Configure**.
2. Open the **Public Hostname** tab and click **Add a public hostname**.
3. **Subdomain:** enter a prefix, e.g. `git`.
4. **Domain:** select your domain from the dropdown.
5. **Service Type:** select **HTTP**.
6. **Service URL:** enter `gitea:3000`.

   Both containers are defined in the same Compose file, so `cloudflared` reaches Gitea's internal port directly through Docker's internal DNS. Use the internal port `3000` here, not `3030`.

7. Click **Save hostname**.

## Phase 4: Initialize Gitea

::: danger Finish this step right away
Until you complete the install screen, anyone who opens your public URL can set up Gitea and create the admin account. Do this step immediately, or run it over your local network at `http://<your-hostname>.local:3030` before you add the public hostname in Phase 3.
:::

1. Open your new public URL in a browser, e.g. `https://git.yourdomain.com`.
2. On the initial configuration screen, change these settings so repository clone URLs are generated correctly:
   - **Database Type:** keep **SQLite3**. It uses little memory, which suits the Pi.
   - **Server Domain:** your Cloudflare hostname, e.g. `git.yourdomain.com`.
   - **Gitea Base URL:** the full URL with HTTPS and a trailing slash, e.g. `https://git.yourdomain.com/`.
3. Scroll to the bottom, expand **Administrator Account Settings**, and create your admin username and password.
4. Optional: under **Server and Third-Party Service Settings**, enable **Disable Self-Registration** so strangers can't sign up on your public instance.
5. Click **Install Gitea**.

## Notes

- **Git over SSH only works on your local network.** The tunnel only forwards HTTP(S). From outside your home, clone and push over HTTPS. Inside your network you can use SSH on port 2222, e.g. `ssh://git@<your-hostname>.local:2222/user/repo.git`.
- **Updating:** run `docker compose pull && docker compose up -d` in `~/gitea`. For predictable updates, replace `latest` with a specific version tag (e.g. `gitea/gitea:1.22`).
- **Backups:** all repositories, settings and the database are stored in `~/gitea/data`. Stop the containers before you copy this folder.
- **Removing everything:** run `docker compose down` in `~/gitea`, then delete the folder and the tunnel in the Cloudflare dashboard.
