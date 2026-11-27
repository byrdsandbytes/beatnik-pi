# Power Consumption & Running Costs

[![Provenance](https://us-central1-human-validated-badge.cloudfunctions.net/badges/provenance/byrdsandbytes/beatnik-pi/docs/hardware/power-consumption/index.md)](https://github.com/byrdsandbytes/beatnik-pi/blob/master/docs/hardware/power-consumption/index.md)

A Beatnik Pi uses very little power. The amplifier version (Amp Pro) uses Class-D amplification and draws roughly 6 to 10 times less than a typical receiver. The DAC/ADC version has no amplifier at all and draws about as much as a phone charger in use.

| Beatnik Pi | Hardware | Idle | Listening | Cost per Year *(on 24/7, 8 h listening)* |
| --- | --- | --- | --- | --- |
| **Amp Pro** | Pi 4B + HiFiBerry Amp4 Pro + USB-C PD board | ~6 W | ~12 W | ~CHF 24 |
| **DAC/ADC** | Pi 4B + HiFiBerry DAC2 ADC Pro | ~4.5 W | ~5 W | ~CHF 14 |

Assumptions: CHF 0.34 / kWh (Bern, 2026, incl. grid fees and VAT) and the Beatnik Pi left on around the clock. Figures are estimates at the wall. The DAC/ADC figures are derived from the Pi 4B's own draw plus the Beatnik software and the sound card, and have not been measured yet.

## Compared to Other Amplifiers

Compared to a Beatnik Pi (Amp Pro), which replaces the amplifier.

| Amplifier | Type | Idle | Listening | Savings with a Beatnik Pi |
| --- | --- | --- | --- | --- |
| [Pioneer VSX-529-K](./pioneer-vsx-529-k.md) | AV receiver, Class-AB | ~45 W | ~75 W | CHF 16–187 per year |
| [Sansui AU-222](./sansui-au-222.md) | Vintage integrated amp, Class-AB | ~18 W | ~30 W | up to CHF 53 per year, when left on |

Want to keep your amplifier? A Beatnik Pi (DAC/ADC) in front of it adds about CHF 14 per year. See [Keep it and add a Beatnik](./sansui-au-222.md#keep-it-and-add-a-beatnik).

Have you measured your own amplifier? Open a pull request with an example page.
