# Spotify Connect

Spotify Connect is in a stable state. The server accepts Spotify Connect streams from the Spotify app and re-distributes them to all your Snapclients.

::: tip Included in Beatnik OS
If you use [Beatnik OS](../../software/flashing.md), Spotify Connect is already installed and configured. The [shell script](../../software/shell-script.md) installs it as well. Only a [manual / bare metal installation](../../software/manual-installation.md) requires you to set it up yourself.
:::

## Component

| Component | Notes |
| --------- | ----- |
| [Librespot](https://github.com/librespot-org/librespot) | handles Spotify Connect |

## Streaming

Open the Spotify app and look for a new **Spotify Connect** device named "Beatnik-Spotify".

## Manual Setup

If you installed the software by hand, see sections 4.2 and 5.3 of the [Manual / Bare Metal Installation](../../software/manual-installation.md) for installing librespot and adding it as a Snapserver source.

## Network Ports

Spotify Connect uses ports 4070 (local inbound) and 80, 443 (outbound WAN). See the [Network and Infrastructure Requirements](../../software/network/requirements.md).
