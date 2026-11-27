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
| `provision.sh` | While the image is being built | Creates and locks the `beatnik` user account, installs Snapcast, Shairport-Sync, Raspotify, the CamillaDSP executable and soundcard driver, the Beatnik Hardware API and Bleno release packages, Docker, and clones the Beatnik Controller. Also sets up the first-boot step below. |
| `snapserver.conf` | While the image is being built | Provides the Snapserver configuration installed by `provision.sh`. The workflow checks it out with the rest of the repository. |
| `shairport-snapcast.conf` | While the image is being built | Provides the Shairport-Sync settings used by both Snapserver AirPlay sources. |
| `firstboot.sh` | Once, the first time a real Pi boots with this image | Starts the Beatnik Controller, then disables itself so it never runs again. |
| `beatnik-firstboot.service` | Real first boot only | Triggers `firstboot.sh` once. |
| `assert_release_not_published.sh` | Before a release build, and again before uploading | Stops the build if the tag's release is already published, so its files can never be swapped. |
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

## Testing changes and releasing

The full process, including troubleshooting, is in the
[Releasing Beatnik OS](../docs/advanced/releasing.md) guide. In short:

- **Test build:** Actions → **Build Beatnik OS Image** → **Run workflow** on your branch.
  The image and a preview `beatnik-repo.json` are uploaded as workflow artifacts. A
  manual run never creates or changes a release.
- **Release:** push a tag like `v1.0.0`. The build creates a **draft** release with the
  `.img.xz` and `beatnik-os-<version>.meta.json` (sizes and checksums).
- **Publish:** click **Publish release** on the draft. `publish-repo-json.yml` then
  verifies the published image against `meta.json` and opens a pull request
  (`chore/repo-json-<version>`) that adds it to `beatnik-repo.json`. Prereleases are
  skipped.
- A published release is final. `assert_release_not_published.sh` makes the build fail
  rather than replace its files, because that breaks the checksums Raspberry Pi Imager
  checks.

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
- The Hardware API and Bleno are installed from their release `.deb` packages.
  Node.js 22 is installed as a system package first, as required by both packages.
- A manual run with "publish" checked created a draft without a tag. Publishing it
  created the tag, which started a second build that replaced the files on the
  already-published release, so the checksums in `beatnik-repo.json` no longer
  matched (v0.8.3: "SHA256 mismatch" in Raspberry Pi Imager). Manual runs are now
  test-only, published releases are never overwritten, and the publish workflow
  hashes the real release file before opening the pull request.
