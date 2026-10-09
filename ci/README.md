# CI/CD Image Pipeline

This builds the `beatnik-os-*.img.xz` release file
automatically, without needing a physical Pi or SD card. It boots a clean Raspberry Pi
OS Lite (Bookworm) image on GitHub's servers, installs everything Beatnik needs, then
shrinks, compresses, and publishes it.

Workflow files:
[`.github/workflows/build-image.yml`](../.github/workflows/build-image.yml) and
[`.github/workflows/publish-repo-json.yml`](../.github/workflows/publish-repo-json.yml)

## Files

| File | When it runs | What it does |
| --- | --- | --- |
| `provision.sh` | While the image is being built | Creates and locks the `beatnik` user account, installs Snapcast, Shairport-Sync, Raspotify, CamillaDSP, the soundcard driver, Beatnik Hardware API, Beatnik Bleno, Docker, and clones the Beatnik Controller - same as the manual setup. Also sets up the first-boot step below. |
| `firstboot.sh` | Once, the first time a real Pi boots with this image | Starts the Beatnik Controller, then disables itself so it never runs again. |
| `beatnik-firstboot.service` | Real first boot only | Triggers `firstboot.sh` once. |
| `update_repo_json.py` | Twice: as a preview during the build, and for real once the release is published | Adds the new release's download link, size, and checksums to `beatnik-repo.json`. |

## The `beatnik` user account

This mirrors the manual setup: `provision.sh` creates a fixed `beatnik` account at
build time, same as if someone had SSH'd in and run `install.sh` by hand, then locks
its password so it can't be logged into directly.

On first real boot, Raspberry Pi Imager resets that account's password if the person
flashing the image keeps the username `beatnik` (the recommended default). If they
choose a different username, Imager creates a separate account instead, and the
locked `beatnik` account is simply left unused.

## Why one step still waits until the Pi's first real boot

While the image is being built, it isn't really "running" like a normal Pi - there's
no background service manager yet. So `provision.sh` can turn services on so they
start automatically later, but can't start them right now, and skips hardware checks
since there's no real hardware to test during the build.

Docker and the Beatnik Controller's files are already installed at build time. The
only thing that has to wait for a real boot is actually starting the Controller,
since that needs a live Docker daemon.

## Testing changes before merging to `master`

1. Push your branch.
2. Go to Actions → **Build Beatnik OS Image** → **Run workflow**, and pick your branch.
3. Leave **publish** unchecked. This still builds the full image, but uploads the
   `.img.xz` file and a matching `beatnik-repo.json` as workflow attachments instead of
   creating a release, so you can test without touching the real release.
4. Download the image and flash it using Raspberry Pi Imager's "Use custom" option,
   then test it following Test A/B from the Iso-Flashing guide. The test
   `beatnik-repo.json`'s download link won't work on its own since no real release was
   published - it's only for checking the generated file looks right.

Pushing a version tag (like `v1.0.0`), or running the workflow with **publish**
checked, builds the image and creates a **draft** GitHub release with the `.img.xz`
attached - it does **not** touch `beatnik-repo.json` yet.

`beatnik-repo.json` only gets updated once you click **Publish release** on GitHub.
A separate workflow (`publish-repo-json.yml`) handles that, so the download link
never goes live before the file behind it is actually public.

## Problems we ran into (so we don't repeat them)

- Raspberry Pi OS Lite doesn't come with `git` installed by default - both
  `provision.sh` and `firstboot.sh` install it before using it.
- `provision.sh` figures out its own folder path at the very start, before it changes
  directories elsewhere. Doing that lookup later would point to the wrong place.
- The "latest" Raspberry Pi OS image online now means Trixie, not Bookworm - so the
  workflow points to a specific, dated Bookworm download link instead. That link will
  need updating again once it's no longer available.
- Package installs sometimes fail partway through with out-of-memory-style errors,
  since the build runs in a virtual/emulated environment. `provision.sh` retries a
  few times before giving up, and the workflow adds extra swap space to make it less
  likely. This mostly affects non-essential installers (Raspotify, Hardware API,
  Bleno), so those are allowed to fail with a warning instead of stopping the build.
- Installing things as `root` with just `HOME` overridden isn't the same as really
  being logged in as a user - other settings can still leak in from the outer build
  environment. Installing the Hardware API and Bleno via a real `beatnik` login
  session avoided this entirely.
