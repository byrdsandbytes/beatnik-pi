# Power Consumption & Running Costs

[![Provenance](https://us-central1-human-validated-badge.cloudfunctions.net/badges/provenance/byrdsandbytes/beatnik-pi/docs/hardware/power-consumption.md)](https://github.com/byrdsandbytes/beatnik-pi/blob/master/docs/hardware/power-consumption.md)

How much electricity does a Beatnik Pi use, and how does that compare to a classic AV receiver? This page compares a typical receiver (Pioneer VSX-529-K, around CHF 800 new) to a Beatnik Pi (Amp Pro), and estimates purchase cost, running costs and total cost over five years.

::: info Short version
A Beatnik Pi costs **about half as much to buy** as a typical AV receiver and uses roughly **6 to 10 times less power**. Over five years, buying a Beatnik Pi instead of a new receiver saves **CHF 400 to 1,350** in total. If you already own a receiver and keep it on all day, a Beatnik Pi still saves around **CHF 115 to 190 per year** in electricity.
:::

## Assumptions

- **Tariff:** Bern, Switzerland, 2026 `ewb Natur.STROM` variable rate of **CHF 0.34 / kWh** (34 Rp./kWh, incl. grid fees, taxes and VAT). Many European tariffs are higher, which makes the savings larger. Costs scale linearly with your tariff.
- **The Beatnik Pi stays on 24/7.** It has no true sub-1 W hardware standby, so when you are not listening it is counted as idle. This is the least favourable assumption for the Beatnik Pi.
- **The Pioneer receiver** is modelled two ways: either switched to **0.1 W standby** when not in use, or **left on 24/7** at idle. The 0.1 W figure only applies with network and HDMI standby disabled; with those enabled (needed for app control or HDMI-CEC), standby draw is higher and the savings grow.
- **Calculation basis:** 365 days per year (8,760 hours).
- All power figures are estimates at the wall, not lab measurements.

## Hardware Profiles & Power Draw

| System | Architecture & Notes | Est. Hardware Cost | Standby / Off | Idle (On) | Typical Listening | Max Rated |
| --- | --- | --- | --- | --- | --- | --- |
| **Pioneer VSX-529-K** *(baseline)* | 5.2-ch Class-AB AV receiver (220–230 V, 50/60 Hz, mfg. Jan 2015). Includes HDMI video processing, high waste heat. | ~CHF 800 (new) | 0.1 W *(higher with HDMI or network standby)* | ~45 W *(40–55 W)* | ~75 W *(60–100 W)* | 450 W |
| **Beatnik Pi (Amp Pro)** | Pi 4B + HiFiBerry Amp4 Pro + Adafruit USB-C PD board (18 V rail) + 65 W USB-C PD PSU. Runs Snapcast, AirPlay, Spotify Connect, CamillaDSP and Docker. | ~CHF 376 (DIY kit) / ~CHF 480 (Plug & Play) | ~0.5–1.5 W *(software shutdown)* | ~6 W | ~12 W *(11–12 W)* | ~70 W *(65 W PD cap)* |
| **Self-sourced Pi 4B + Amp4 Pro** *(reference)* | Same amplifier, own 20 V / 4 A PSU, without the Beatnik software stack | ~CHF 150–180 | ~0.5–1.5 W *(software shutdown)* | ~5 W *(4–6 W)* | ~10 W *(6–15 W)* | ~80 W |
| **Raspberry Pi 4B (1GB)** *(reference)* | Single-board computer only, no amplifier | – | ~0.1 W | ~3 W *(2.5–3 W)* | ~6 W *(active load)* | 15 W *(PSU limit)* |

See [Hardware Examples](./overview.md#beatnik-server-amp-pro) for the full Amp Pro parts list. Beatnik OS is free, so you can also source the parts yourself and run it on the self-sourced build.

## Yearly Consumption, Cost & Savings

At CHF 0.34 / kWh. Savings are for the Beatnik Pi (Amp Pro) compared to the Pioneer.

| Usage Scenario | Pioneer VSX-529-K | Beatnik Pi (Amp Pro) | Savings per Year | Savings over 5 Years |
| --- | --- | --- | --- | --- |
| **24/7 continuous listening** *(shop, bar, office)* | 657 kWh / **CHF 223** | 105 kWh / **CHF 36** | **CHF 187** | **CHF 935** |
| **8 h listening / 16 h idle** *(all left on)* | 482 kWh / **CHF 164** | 70 kWh / **CHF 24** | **CHF 140** | **CHF 700** |
| **4 h listening / 20 h idle** *(all left on)* | 438 kWh / **CHF 149** | 61 kWh / **CHF 21** | **CHF 128** | **CHF 640** |
| **24/7 idle only** | 394 kWh / **CHF 134** | 53 kWh / **CHF 18** | **CHF 116** | **CHF 580** |
| **8 h listening / 16 h standby** *(Pioneer off, Beatnik on)* | 220 kWh / **CHF 75** | 70 kWh / **CHF 24** | **CHF 51** | **CHF 255** |
| **4 h listening / 20 h standby** *(Pioneer off, Beatnik on)* | 110 kWh / **CHF 37** | 61 kWh / **CHF 21** | **CHF 16** | **CHF 80** |

In every scenario the Beatnik Pi is cheaper to run, even though it stays on around the clock and the receiver is switched off.

### Multi-room

The savings add up per room. Replacing two receivers that are left on with two Beatnik Pis at 8 h of listening a day saves around **CHF 280 per year**, or **CHF 1,400 over five years**.

## Why the Difference?

- **Amplifier class.** The Pioneer uses Class-AB amplification plus video circuitry, which burns around 45 W even when nothing is playing. The Beatnik Pi uses Class-D amplification, so idle and low-volume losses stay minimal.
- **Less waste heat.** Almost all of the power a receiver draws ends up as heat. A Beatnik Pi runs cool and fits in a much smaller space.
- **USB-C PD overhead.** The Adafruit USB-C PD board adds a negligible draw (under 0.1 W). The 1–2 W extra compared to a bare Pi + Amp4 Pro comes from the software that makes it a Beatnik: CamillaDSP, Snapcast and Docker.

## Total Cost over 5 Years

Buying new: purchase price plus five years of electricity. The receiver is ~CHF 800, the Beatnik Pi CHF 376 (DIY kit) or CHF 480 (Plug & Play).

| Usage Scenario | Pioneer VSX-529-K | Beatnik Pi DIY Kit | Beatnik Pi Plug & Play | You Save |
| --- | --- | --- | --- | --- |
| **24/7 continuous listening** *(shop, bar, office)* | CHF 1,915 | CHF 556 | CHF 660 | **CHF 1,255–1,359** |
| **8 h listening / 16 h idle** *(all left on)* | CHF 1,620 | CHF 496 | CHF 600 | **CHF 1,020–1,124** |
| **4 h listening / 20 h idle** *(all left on)* | CHF 1,545 | CHF 481 | CHF 585 | **CHF 960–1,064** |
| **24/7 idle only** | CHF 1,470 | CHF 466 | CHF 570 | **CHF 900–1,004** |
| **8 h listening / 16 h standby** *(Pioneer off, Beatnik on)* | CHF 1,175 | CHF 496 | CHF 600 | **CHF 575–679** |
| **4 h listening / 20 h standby** *(Pioneer off, Beatnik on)* | CHF 985 | CHF 481 | CHF 585 | **CHF 400–504** |

The Beatnik Pi is cheaper from day one, so there is no payback period: it saves money on the purchase and keeps saving on electricity.

### If you already own a receiver

If you replace a receiver that still works, the electricity savings pay back the Beatnik Pi in **2–2.6 years** with continuous playback, and in **3–4 years** if the receiver would otherwise be left on. A self-sourced Pi 4B + Amp4 Pro (CHF 150–180) pays for itself in under a year with continuous playback.

### Beyond cost

On top of the savings, a Beatnik Pi gives you a compact footprint, much less waste heat, synchronized multi-room audio, AirPlay and Spotify Connect built in, and CamillaDSP room correction.

## Next

- [Choosing the Right Hardware](./choosing-hardware.md) – decide between amplifier and DAC.
- [Hardware Examples](./overview.md) – complete parts lists for a server and a client.
