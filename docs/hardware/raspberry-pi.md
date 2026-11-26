# Raspberry Pi Models

The complete list of Raspberry Pi models and how they work with Beatnik. For a short summary, see [Compatibility](./compatibility.md).

## Requirements

- **64-bit OS (`arm64`).** Snapcast, CamillaDSP and the Beatnik Bleno service are only shipped for 64-bit. Models that can't run a 64-bit OS are not supported.
- **5 GHz Wi-Fi recommended.** Audio streams continuously to every client, and the 5 GHz band is usually far less crowded than 2.4 GHz, which means fewer dropouts. Wired Ethernet is better still.
- **A 40-pin GPIO header** if you want to use a sound card HAT.

## RAM

| Role | Recommended | Minimum |
|------|-------------|---------|
| Server | 2 GB | 1 GB |
| Client | 1 GB | 512 MB |

Heavy CamillaDSP configs (many filters, mixers or compressors) benefit from more RAM and a faster CPU.

## All models

| Model | RAM | 64-bit | 5 GHz Wi-Fi | Ethernet | Status | Role |
|-------|-----|--------|-------------|----------|--------|------|
| **Pi 4B** | 1, 2, 4 or 8 GB | Yes | Yes | Gigabit | Recommended | Server or client. Pick 2 GB or more for a server. 1 GB is fine for a client or a light server. |
| **Pi 3B+** | 1 GB | Yes | Yes | Yes (USB 2.0 limited) | Recommended | Client, or a light server. |
| **Pi 3A+** | 512 MB | Yes | Yes | No | Recommended | Client only. |
| **Pi 3B** | 1 GB | Yes | No | Yes | Works | Client. 2.4 GHz only, fine on a clean network or with Ethernet. |
| **Pi 5** | 1, 2, 4, 8 or 16 GB | Yes | Yes | Gigabit | Works, not recommended | Server or client, but runs hot under a HAT. Needs active cooling. |
| **Pi Zero 2 W** | 512 MB | Yes | No | No | Untested | Client only. 2.4 GHz only. |
| **Pi 400** | 4 GB | Yes | Yes | Gigabit | Untested | GPIO header is on the back, so HATs need an adapter. |
| **Pi 500 / 500+** | 8 GB / 16 GB | Yes | Yes | Gigabit | Untested | Same heat considerations as the Pi 5. |
| **Compute Modules** | CM3: 1 GB, CM4: 1 to 8 GB, CM5: 2 to 16 GB | Yes | Depends on module | Depends on carrier board | Untested | Depends on the carrier board. |
| **Pi 2B v1.2** | 1 GB | Yes | No | Yes | Untested | 64-bit capable (same chip as the Pi 3B), but no Wi-Fi. Client at most. |
| **Pi 2B v1.1** | 1 GB | No | No | Yes | Not supported | No 64-bit support. |
| **Pi 1 (A, B, A+, B+)** | 256 or 512 MB | No | No | B / B+ only | Not supported | No 64-bit support. |
| **Pi Zero / Zero W** | 512 MB | No | No | No | Not supported | No 64-bit support. |

Wi-Fi on the Pi 2B, and on any Pi without built-in Wi-Fi, needs a USB adapter.

::: tip Which model and RAM do I have?
On the Pi, run:

```bash
cat /proc/device-tree/model   # e.g. "Raspberry Pi 4 Model B Rev 1.5"
free -h                       # total RAM
```
:::

**Status** means:

- **Recommended** – tested and the best fit for Beatnik.
- **Works** – supported, with the limitation in the notes.
- **Untested** – should run a 64-bit OS, but we haven't confirmed it with Beatnik. Please [let us know](https://www.reddit.com/r/beatnikAudio/) how it goes.
- **Not supported** – can't run a 64-bit OS.

## Why not the Pi 5?

The Pi 5 is faster, but Beatnik doesn't need that extra speed for streaming and DSP. It runs noticeably hotter than a Pi 4B, and a sound card HAT sits right on top of the SoC, which traps the heat, especially in a closed case. Without active cooling it can throttle. If you use one, give it a fan or a cooling case with enough airflow.

## Next

- [Sound Cards](./soundcards.md) – pick the audio board.
- [Compatibility](./compatibility.md) – back to the overview.
