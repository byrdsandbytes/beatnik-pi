# AirPlay

AirPlay (1 & 2) is in a stable state. The server accepts AirPlay streams from any smartphone, laptop or PC and re-distributes them to all your Snapclients.

::: tip Included in Beatnik OS
If you use [Beatnik OS](../../software/flashing.md), AirPlay is already installed and configured. The [shell script](../../software/shell-script.md) installs it as well. Only a [manual / bare metal installation](../../software/manual-installation.md) requires you to set it up yourself.
:::

## Component

| Component | Notes |
| --------- | ----- |
| [Shairport-Sync](https://github.com/mikebrady/shairport-sync) | **4.3.x** / handles AirPlay 1+2 |

## Streaming

From your phone or computer, look for a new **AirPlay** device named "Beatnik-Airplay".

## Manual Setup

If you installed the software by hand, see sections 4.1, 5.1 and 5.2 of the [Manual / Bare Metal Installation](../../software/manual-installation.md) for installing Shairport-Sync and adding it as a Snapserver source.

## Network Ports

AirPlay 1 & 2 use ports 5000 and 7000. See the [Network and Infrastructure Requirements](../../software/network/requirements.md).
