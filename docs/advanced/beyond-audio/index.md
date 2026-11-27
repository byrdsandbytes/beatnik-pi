# Beyond Audio: Running Other Services on Your Beatnik Pi

[![Provenance](https://us-central1-human-validated-badge.cloudfunctions.net/badges/provenance/byrdsandbytes/beatnik-pi/docs/advanced/beyond-audio/index.md)](https://github.com/byrdsandbytes/beatnik-pi/blob/master/docs/advanced/beyond-audio/index.md)

Your Beatnik Pi is a full Linux computer that's usually on, so it can also run small self-hosted services next to the audio stack. The guides in this section show how to install tools that have nothing to do with Beatnik itself.

::: warning Unofficial and unsupported
These services aren't part of Beatnik. We don't test them against Beatnik updates, and anything you install here is yours to maintain. If something stops working, first stop the extra services and check whether the audio problem goes away.
:::

## Ground rules

Every guide in this section follows these conventions so the extra services don't get in the way of playback:

- **Use Docker.** Docker and the Compose plugin come pre-installed on Beatnik OS. Containers keep each tool isolated from the audio components, and you can remove one completely with `docker compose down`.
- **Give each service its own folder** in your home directory, e.g. `~/gitea`, holding its `docker-compose.yml` and data.
- **Avoid ports Beatnik already uses.** Don't map a container to any of these:

  | Port | Used by |
  | --- | --- |
  | 80 | Beatnik Controller |
  | 3000 | Beatnik Hardware API |
  | 1704, 1705, 1780 | Snapcast |
  | 5000, 7000 | AirPlay |

- **Keep an eye on resources.** Audio playback needs steady CPU time. Heavy workloads such as CI runners, media transcoding or large databases can cause dropouts, especially on a Pi with 1–2 GB of RAM. Check usage with `docker stats` or `htop`.
- **Don't open ports on your router.** If you want a service reachable from the internet, use a tunnel such as Cloudflare Tunnel, as the guides here do.

## Guides

- [Gitea (self-hosted Git) with Cloudflare Tunnel](./gitea.md)
