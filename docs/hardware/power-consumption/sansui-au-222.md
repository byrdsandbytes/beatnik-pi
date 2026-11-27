# Example: Sansui AU-222

[![Provenance](https://us-central1-human-validated-badge.cloudfunctions.net/badges/provenance/byrdsandbytes/beatnik-pi/docs/hardware/power-consumption/sansui-au-222.md)](https://github.com/byrdsandbytes/beatnik-pi/blob/master/docs/hardware/power-consumption/sansui-au-222.md)

A vintage integrated amplifier (1968–1971) compared to a Beatnik Pi (Amp Pro). For the general assumptions see [Power Consumption](./index.md).

::: info Short version
The AU-222 is far more efficient than a modern AV receiver, because it only drives two modest channels and has no video, DSP or network hardware. Left on, it costs **CHF 36 to 53 more per year** than a Beatnik Pi. Switched off after listening, the two are roughly even.
:::

## Power Draw

| System | Notes | Off | Idle (On) | Typical Listening | Max Rated |
| --- | --- | --- | --- | --- | --- |
| **Sansui AU-222** | 2-ch solid-state Class-AB, 18 W RMS per channel into 8 Ω, linear power supply | 0 W *(mechanical mains switch)* | ~18 W *(rated 20 VA)* | ~30 W *(25–35 W)* | ~85–100 W *(rated 100 VA)* |
| **Beatnik Pi (Amp Pro)** | Class-D, see [Power Consumption](./index.md) | – *(stays on)* | ~6 W | ~12 W | ~70 W |

Sansui rated the AU-222 in VA (apparent power), not watts. With the power factor of a vintage linear transformer (about 0.8–0.9), the billed power at idle is around 16–18 W. These pages use 18 W.

## Yearly Running Costs

At CHF 0.34 / kWh.

| Usage Scenario | Sansui AU-222 | Beatnik Pi | Difference per Year |
| --- | --- | --- | --- |
| **24/7 continuous listening** | 263 kWh / CHF 89 | 105 kWh / CHF 36 | **Beatnik saves CHF 53** |
| **8 h listening / 16 h idle** *(all left on)* | 193 kWh / CHF 66 | 70 kWh / CHF 24 | **Beatnik saves CHF 42** |
| **4 h listening / 20 h idle** *(all left on)* | 175 kWh / CHF 60 | 61 kWh / CHF 21 | **Beatnik saves CHF 39** |
| **24/7 idle only** | 158 kWh / CHF 54 | 53 kWh / CHF 18 | **Beatnik saves CHF 36** |
| **8 h listening / 16 h off** *(Sansui switched off)* | 88 kWh / CHF 30 | 70 kWh / CHF 24 | **Beatnik saves CHF 6** |
| **4 h listening / 20 h off** *(Sansui switched off)* | 44 kWh / CHF 15 | 61 kWh / CHF 21 | **Sansui saves CHF 6** |

## Keep it and add a Beatnik

A vintage amp like the AU-222 is worth keeping. Instead of replacing it, put a Beatnik Pi (DAC/ADC) in front of it: the Sansui keeps its sound, and you get AirPlay, Spotify Connect, multi-room sync and CamillaDSP room correction. See [Choosing the Right Hardware](../choosing-hardware.md#dac-or-amp).

The Beatnik Pi (DAC/ADC) draws about 4.5 W idle and 5 W while playing, and stays on 24/7. Switch the Sansui off when you are not listening and it costs:

| Usage Scenario | Sansui AU-222 | Beatnik Pi (DAC/ADC) | Total per Year |
| --- | --- | --- | --- |
| **4 h listening / 20 h off** | CHF 15 | CHF 14 | **CHF 29** |
| **8 h listening / 16 h off** | CHF 30 | CHF 14 | **CHF 44** |

That is about CHF 1 to 1.20 per month to turn a 50-year-old amplifier into a streaming, multi-room system.
