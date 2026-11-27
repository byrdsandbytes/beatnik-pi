# Releasing Beatnik OS

This page is for maintainers. It explains how a new Beatnik OS image gets from a git tag into Raspberry Pi Imager, and what to do when something goes wrong.

## How it fits together

A release goes through two GitHub Actions workflows and one pull request:

| Step | Who | What happens |
| --- | --- | --- |
| 1. Push a tag | You | `git push origin v0.9.0` |
| 2. Build | [`build-image.yml`](https://github.com/byrdsandbytes/beatnik-pi/blob/master/.github/workflows/build-image.yml) | Builds the image (about 15 minutes) and creates a **draft** release with two files: `beatnik-os-v0.9.0.img.xz` and `beatnik-os-v0.9.0.meta.json` (sizes and SHA256 checksums). |
| 3. Publish | You | Open the draft on GitHub and click **Publish release**. |
| 4. Verify and open PR | [`publish-repo-json.yml`](https://github.com/byrdsandbytes/beatnik-pi/blob/master/.github/workflows/publish-repo-json.yml) | Downloads the published image, checks it against `meta.json`, adds the release to `beatnik-repo.json` and opens a pull request `chore/repo-json-v0.9.0`. |
| 5. Merge | You | Merge the pull request. From then on, Raspberry Pi Imager offers the new version. |

`beatnik-repo.json` is the list Raspberry Pi Imager reads. It holds the download link and the checksums of every image. Imager downloads the image, computes its SHA256 and compares it with the value in `beatnik-repo.json`. If the two differ, the installation fails. Most of the rules below exist to keep these two in sync.

## Releasing a new version

1. Make sure everything you want to ship is merged into `master`.
2. Optional but recommended: do a [test build](#test-builds) first and flash it.
3. Tag `master` and push the tag:

   ```bash
   git switch master
   git pull
   git tag v0.9.0
   git push origin v0.9.0
   ```

4. Wait for **Build Beatnik OS Image** to finish under the Actions tab.
5. Go to **Releases**, open the draft `Beatnik OS v0.9.0`, write the release notes and click **Publish release**.
6. Wait for **Publish beatnik-repo.json** to finish. It opens a pull request named `chore: add v0.9.0 to beatnik-repo.json`.
7. Before merging, you can test the exact result: check out the PR branch and point Raspberry Pi Imager at its `beatnik-repo.json`.
8. Merge the pull request.

## Test builds

Go to Actions, then **Build Beatnik OS Image**, then **Run workflow**, and pick your branch. You can give the image a label, otherwise it is called `test-<commit>`.

A test build never creates or changes a release. When it finishes, the run page has two downloads:

- the `.img.xz` image, to flash with Raspberry Pi Imager ("Use custom")
- `beatnik-repo-preview`, containing the `meta.json` and a preview of `beatnik-repo.json`

Downloads are kept for 7 days.

## Prereleases

A tag with a suffix, such as `v0.9.0-rc1` or `v0.9.0-beta.2`, creates a draft marked as a prerelease. Publishing it makes the image downloadable from GitHub, but `beatnik-repo.json` is not changed, so Raspberry Pi Imager will not offer it.

## Rules

- **Only release by pushing a tag.** Do not create releases by hand on the GitHub releases page. A release created there with a new tag starts a second build.
- **A published release is final.** Never upload, replace or delete files on a published release. If an image turns out to be broken, fix it and release a new patch version (for example `v0.9.1`). The build workflow refuses to upload to a published release.
- **Before publishing, the draft is yours to redo.** If a build fails or the draft image is bad, you can re-run the build, or delete the draft and the tag and start again:

  ```bash
  git push --delete origin v0.9.0
  git tag -d v0.9.0
  ```

## One-time repository setup

`master` is protected, so the workflow opens a pull request instead of pushing. GitHub only allows this when **Settings, Actions, General, "Allow GitHub Actions to create and approve pull requests"** is enabled.

## Troubleshooting

### Raspberry Pi Imager: "SHA256 mismatch" / "SHA256-Hash stimmt nicht überein"

The file on the release is not the one `beatnik-repo.json` describes. This happens when the release files were replaced after the checksums were recorded, for example by a second build. The safeguards above now prevent this. Do not fix it by editing the checksums by hand. Tag a new patch version instead.

To check a release yourself:

```bash
curl -L -O https://github.com/byrdsandbytes/beatnik-pi/releases/download/v0.9.0/beatnik-os-v0.9.0.img.xz
shasum -a 256 beatnik-os-v0.9.0.img.xz        # compare with image_download_sha256
xz -dc beatnik-os-v0.9.0.img.xz | shasum -a 256  # compare with extract_sha256
```

### "Publish beatnik-repo.json" failed at "Verify release image matches metadata"

The image on the release does not match its `meta.json`. Do not merge or create a `beatnik-repo.json` entry for this release. Release a new patch version.

### "Publish beatnik-repo.json" failed or never ran

Run it by hand: Actions, then **Publish beatnik-repo.json**, then **Run workflow**, and enter the tag (for example `v0.9.0`). It works for any published release, and running it again for the same tag updates the existing pull request instead of opening a second one.

### The pull request has checks that never start

GitHub does not start other workflows for pull requests opened by GitHub Actions. If `master` requires status checks, close and reopen the pull request to start them.

### "Build Beatnik OS Image" failed with "Release ... is already published"

Someone pushed a tag, or re-ran a build, for a version that is already published. This is the safeguard working as intended. Use a new version number.
