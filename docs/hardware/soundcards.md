# Sound Cards

The complete list of sound cards supported by Beatnik. For a short summary, see [Compatibility](./compatibility.md).

## How it works

Beatnik ships a profile for each sound card below. A profile sets the device tree overlay in `config.txt` and configures CamillaDSP with the right ALSA device and sample format. Cards with an EEPROM (most HiFiBerry boards) are detected automatically. Otherwise you pick the card in the app during setup.

**Tested** shows who has confirmed the card works with Beatnik:

- **Beatnik** – tested by the Beatnik team.
- **Community** – reported working by users.
- **–** – a profile exists but nobody has confirmed it yet. It should work. Please [let us know](https://www.reddit.com/r/beatnikAudio/) how it goes.

## DACs

For active speakers, an existing amp or a receiver.

| Sound card | Overlay | Format | Line-In | Tested |
|------------|---------|--------|---------|--------|
| [HiFiBerry DAC+ ADC Pro / DAC2 ADC Pro](../software/soundcards/hifiberry-dac-adc-pro.md) | `hifiberry-dacplusadcpro` | S32LE | Yes | Beatnik |
| HiFiBerry DAC+ ADC | `hifiberry-dacplusadc` | S32LE | Yes | – |
| HiFiBerry DAC+ Pro / DAC2 Pro | `hifiberry-dacplus-pro` | S32LE | No | – |
| HiFiBerry DAC+ Standard | `hifiberry-dacplus-std` | S32LE | No | – |
| HiFiBerry DAC2 HD | `hifiberry-dacplushd` | S32LE | No | – |
| HiFiBerry DAC / MiniAmp / Beocreate / DAC+ Light | `hifiberry-dac` | S32LE | No | – |
| HiFiBerry DAC8x | `hifiberry-dac8x` | S32LE | No | – |
| [IQaudIO Pi-DAC PRO](../software/soundcards/iqaudio-dacPro.md) / [DAC+](../software/soundcards/raspberry-dacPlus.md) | `iqaudio-dacplus` | S32LE | No | – |

## Amplifiers

For passive speakers. Connect them directly to the board.

| Sound card | Overlay | Format | Tested |
|------------|---------|--------|--------|
| [HiFiBerry Amp4 Pro](../software/soundcards/hifiberry-amp4Pro.md) | `hifiberry-amp4pro` | S32LE | Beatnik, Community |
| [Raspberry Pi DigiAMP+](../software/soundcards/raspberry-digiAmpPlus.md) | `iqaudio-digiamp-plus,unmute_amp` | S32LE | Beatnik |
| HiFiBerry Amp2 / Amp4 | `hifiberry-dacplus-std` | S32LE | – |

The older HiFiBerry **Amp+** and **Amp3** have no profile and are not supported.

## Digital outputs

For an external DAC or receiver with an S/PDIF input.

| Sound card | Overlay | Format | Tested |
|------------|---------|--------|--------|
| [HiFiBerry Digi / Digi+ / Digi 2 Standard](../software/soundcards/hifiberry-digi.md) | `hifiberry-digi` | S24LE3 | Community |
| [HiFiBerry Digi+ Pro / Digi 2 Pro](../software/soundcards/hifiberry-digi-pro.md) | `hifiberry-digi-pro` | S24LE3 | Community |

## Without a HAT

| Output | ALSA device | Format | Tested |
|--------|-------------|--------|--------|
| Generic USB DAC | `hw:1,0` | S16LE | – |
| Raspberry Pi HDMI 0 | `hw:CARD=vc4hdmi0,DEV=0` | S16LE | – |
| Headphone jack (no HAT) | `hw:0,0` | S16LE | – |

USB DACs differ a lot. If yours doesn't play, check its card number and supported formats with `aplay -l` and `aplay --dump-hw-params -D hw:1,0 /dev/zero`. The headphone jack works for testing but sounds noticeably worse than a proper DAC.

## Line-In

Line-In lets you stream an analog source, such as a turntable, CD player, mixer or phone, to every Beatnik in your home. You need a sound card with an **ADC** (analog-to-digital converter), which has a line input next to its output.

| Sound card | Tested |
|------------|--------|
| [HiFiBerry DAC+ ADC Pro / DAC2 ADC Pro](../software/soundcards/hifiberry-dac-adc-pro.md) | Beatnik |
| HiFiBerry DAC+ ADC | – |

Things to know:

- **Server only.** Line-In feeds the Snapcast server directly, so the card must be on the device that runs as your server. On a client the Line-In (preamp) service is turned off.
- **Turntables need a phono preamp.** A turntable puts out a much weaker phono signal than line level. Use a turntable with a built-in preamp, or put an external phono preamp in between.
- **Separate DSP.** Line-In has its own CamillaDSP instance, independent of the playback output. Use it for gain, RIAA correction or levelling. See [Camilla DSP and Equalising](../usage/guide-camilladsp.md).
- **Included in Beatnik OS 0.8+.** Line-In is installed and configured automatically. For a manual setup, see [Line-In](../features/line-in.md). For the full signal path, see [Audio Pipelines](../features/pipelines.md).

## Next

- [Raspberry Pi Models](./raspberry-pi.md)
- [Hardware Examples](./overview.md)
