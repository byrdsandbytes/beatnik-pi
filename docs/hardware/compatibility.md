# Compatibility

An overview of the hardware that works with Beatnik. For every model and card, see the complete lists:

- [Raspberry Pi Models](./raspberry-pi.md)
- [Sound Cards](./soundcards.md)

## Raspberry Pi

Beatnik needs a Pi that runs a **64-bit OS**. The best fit is a model with **5 GHz Wi-Fi**, which gives fewer dropouts than 2.4 GHz.

| Model | RAM | Status | Best for |
|-------|-----|--------|----------|
| **Pi 4B** | 1 to 8 GB | Recommended | Server (2 GB+) or client |
| **Pi 3B+** | 1 GB | Recommended | Client |
| **Pi 3A+** | 512 MB | Recommended | Client |
| **Pi 3B** | 1 GB | Works | Client (2.4 GHz only) |
| **Pi 5** | 1 to 16 GB | Works, not recommended | Runs hot under a HAT. Needs active cooling. |

Pi 1, Pi 2B v1.1 and Pi Zero / Zero W are not supported. See [Raspberry Pi Models](./raspberry-pi.md) for all models.

::: tip
A wired Ethernet connection beats any Wi-Fi. If a device sits next to your router, plug it in.
:::

## Sound cards

Tested by the Beatnik team:

| Sound card | Type | Use with |
|------------|------|----------|
| **HiFiBerry Amp4 Pro** | Amplifier | Passive speakers |
| **Raspberry Pi DigiAMP+** | Amplifier | Passive speakers |
| **HiFiBerry DAC+ ADC Pro / DAC2 ADC Pro** | DAC + ADC | Active speakers, amp or receiver. Also has Line-In. |

Reported working by the community: **HiFiBerry Digi / Digi+ / Digi 2** (standard and Pro), for receivers with an S/PDIF input.

Profiles also exist for more HiFiBerry and IQaudIO boards, USB DACs, HDMI and the headphone jack. See [Sound Cards](./soundcards.md) for the full list.

## Line-In

To stream an analog source such as a turntable to every room, use a sound card with an ADC, for example the **HiFiBerry DAC+ ADC Pro**. It must be on the device that runs as your server. See [Sound Cards – Line-In](./soundcards.md#line-in).

## Next

See [Hardware Examples](./overview.md) for complete parts lists.
