# CI/CD Image Pipeline

This builds the `beatnik-os-*.img.xz` release file (server + HiFiBerry Amp4 Pro)
automatically, without needing a physical Pi or SD card. It uses
[`pguyot/arm-runner-action`](https://github.com/pguyot/arm-runner-action) to start up
a clean Raspberry Pi OS Lite (Bookworm) image in a virtual environment on GitHub's
servers, install everything Beatnik needs onto it, then shrink, compress, and publish it.

Workflow files:
[`.github/workflows/build-image.yml`](../.github/workflows/build-image.yml) and
[`.github/workflows/publish-repo-json.yml`](../.github/workflows/publish-repo-json.yml)

## Files

| File | When it runs | What it does |
| --- | --- | --- |
| `provision.sh` | While the image is being built | Creates and locks the `beatnik` user account, installs Snapcast, Shairport-Sync, Raspotify, CamillaDSP, the soundcard driver, Beatnik Hardware API, Beatnik Bleno, Docker, and clones the Beatnik Controller - all under `/home/beatnik`, same as the manual setup. Also sets up the first-boot step below. |
| `firstboot.sh` | Once, the first time a real Pi boots with this image | Starts the Beatnik Controller with `docker compose up -d`, then turns itself off so it never runs again. |
| `beatnik-firstboot.service` | Real first boot only | The background job that triggers `firstboot.sh` once. |
| `update_repo_json.py` | Twice: as a preview during the build, and for real once the release is published | Adds the new release's download link, size, and checksums to `beatnik-repo.json`. |

## The `beatnik` user account

This mirrors the manual golden-master process (`cleanup.sh`): `provision.sh` creates a
fixed `beatnik` account at build time, adds it to the usual groups (audio, gpio, sudo,
etc.), gives it passwordless sudo, and then **locks its password**. Everything
Beatnik-specific (CamillaDSP, Hardware API, Bleno, Controller) is installed under
`/home/beatnik`, exactly as if someone had SSH'd in as `beatnik` and run `install.sh` by
hand.

On first real boot, Raspberry Pi Imager's `userconf-service` (installed via
`raspberrypi-sys-mods`) resets that account's password if the person flashing the image
chooses the username `beatnik` (the recommended default). If they choose a different
username, Imager creates a separate new account instead, and the locked `beatnik`
account is simply left unused.

## Why one step still waits until the Pi's first real boot

While the image is being built, it isn't really "running" the way a normal Pi does -
there's no fully working background service manager yet. Because of that,
`provision.sh` can turn services on so they'll start automatically later, but can't
actually start them right now, and it skips any hardware checks (like testing the
sound card), since there's no real hardware to test against during the build.

Docker itself, and the Beatnik Controller's files, are already installed and cloned
at build time. The only thing that has to wait for a real boot is actually starting
it with `docker compose up -d`, since that needs a live Docker daemon.

## Testing changes before merging to `master`

1. Push your branch.
2. Go to Actions → **Build Beatnik OS Image** → **Run workflow**, and pick your branch
   from the branch dropdown.
3. Leave **publish** unchecked. This still builds the full image, but instead of
   creating a release, it uploads the `.img.xz` file and a matching `beatnik-repo.json`
   as downloadable attachments on the workflow run, so you can test both without
   touching the real release or the tracked `beatnik-repo.json`.
4. Download the image and flash it using Raspberry Pi Imager's "Use custom" option,
   then test it following Test A/B from the Iso-Flashing guide. Note that the test
   `beatnik-repo.json`'s download link won't work on its own since no real release was
   published - it's only for checking the generated file looks right.

Pushing a version tag (like `v1.0.0`), or manually running the workflow with
**publish** checked, builds the image and creates a **draft** GitHub release with the
`.img.xz` attached (plus a small metadata file with its checksums/sizes) - it does
**not** touch `beatnik-repo.json` yet.

`beatnik-repo.json` only gets updated and committed to `master` once you actually
click **Publish release** on GitHub. That's handled by a separate workflow
(`publish-repo-json.yml`), triggered by GitHub's "release published" event, so the
download link in `beatnik-repo.json` never goes live before the file behind it is
actually public.

## Problems we ran into (so we don't repeat them)

- Raspberry Pi OS Lite doesn't come with `git` installed by default - both
  `provision.sh` and `firstboot.sh` install it explicitly before using it.
- `provision.sh` figures out its own folder path at the very start, before it changes
  directories elsewhere in the script. If that lookup were done later, it would point
  to the wrong place.
- The "latest" Raspberry Pi OS image online now means Trixie, not Bookworm - so the
  workflow points to a specific, dated Bookworm download link instead. That link will
  need to be updated again eventually when it's no longer available.
- Sometimes a package install fails partway through with an out-of-memory-style error,
  caused by running Raspberry Pi software in a virtual/emulated environment on GitHub's
  servers. `provision.sh` retries these a few times before giving up, and the workflow
  adds extra swap space before the build to make it less likely in the first place.
  It mostly affects non-essential installers (Raspotify, Hardware API, Bleno), so those
  steps are still allowed to fail with a warning instead of stopping the whole build.
- Installing things as `root` with just `HOME` overridden isn't the same as really
  being logged in as a user - other login-related settings can still leak in from
  the outer build environment. Installing the Hardware API and Bleno via `su - beatnik`
  instead (a real login session) avoided this entirely.
