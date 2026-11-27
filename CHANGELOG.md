# Changelog

All notable changes to Beatnik Pi are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Entries before this file existed were reconstructed from the git history.

## [Unreleased]

### Added
- Migration guide for moving from 0.6 to 0.8, including a scripted migration and screenshots (#69, #71, #72, #73, #74).
- More detailed Raspberry Pi and soundcard recommendations; docs restructured and cross-linked (#76, #77).
- Human doc validation concept: provenance badge and review tag on all docs (#78 to #84).
- ADC mentioned in the README installation instructions (#75).

### Changed
- Docs split into smaller pages (#84).
- Server docs adapted to the "all server" concept introduced in 0.8.
- Comment in `ci/snapserver.conf` now notes that Spotify volume normalization is enabled. Thanks to Yuri van Geffen (@yurivangeffen) for the feedback and discussion.

### Fixed
- CI builds no longer conflict when several test releases are built manually with the same version (#85).
- Gitea-related fixes in the docs (#69).

## [0.8.3] - 2026-11-23

### Added
- First "beyond audio" docs about running other software on a Beatnik Pi (#68).

### Changed
- The pipeline now opens a pull request to update `beatnik-repo.json` instead of pushing to master (#67).

## [0.8.2] - 2026-11-23

### Fixed
- Pipeline did not push `beatnik-repo.json` correctly (#66).
- Outdated versions in `beatnik-repo.json`.

## [0.8.1] - 2026-11-17

### Changed
- Architecture documentation updated with new links.
- Badge syntax updated.
- First test of the human validation concept for docs ("Reviewed-by" labels).

## [0.8.0] - 2026-11-09

### Added
- Snapserver configuration (`ci/snapserver.conf`) shipped with the image, including Spotify volume normalization (#63).
- Documentation site generated from the README, with FAQ and workflow pages (#59).
- Status and docs badges in the README (#64).

### Changed
- CI configuration moved into separate files (#58).
- Architecture graph replaced (#56).
- Feature list in the docs improved (#62).

### Fixed
- Ubuntu version in the CI pipeline (#58).
- Images not loading on the docs front page and a dead link (#60, #61).

## [0.7.10] - 2026-10-17

### Added
- CI pipeline that builds Beatnik OS images (based on Raspberry Pi OS Bookworm) and generates `beatnik-repo.json` for Raspberry Pi Imager (#40 to #47, #55).
- Installation docs rewritten: introduction, overview, usage section, installation paths and images (#48).
- Additional guides (#49).
- License and copyright notice (#50).
- Raspberry Pi 4B and 3B listed as supported (#48).

### Changed
- Installation moved into the `beatnik` user folder (#45).
- First-boot script now waits for Docker and time sync before starting (#51).

### Fixed
- Docker containers starting too early or not at all on first boot.
- Spotify (raspotify / librespot) install and crash issues (#47, #54).
- Memory issue during the image build (#44).
- Missing `firstboot.sh` and missing git version in the build (#41, #42).
- Missing images, links and acknowledgments in the docs (#51, #52, #53).
- Removed an old, unused port.

## [0.7.0] - 2026-09-23

### Added
- Network debugging guide with buffering configuration tips (#37).
- Default volume configuration docs.
- Assets for Raspberry Pi Imager.

### Changed
- Install shell script updated and README adjusted to match (#38, #39).

## [0.6.1] - 2026-08-04

### Added
- Acknowledgments section in the README.

## [0.6.0] - 2026-07-28

### Added
- Network requirements documentation (#36).
- Beatnik OS 0.6 added to `beatnik-repo.json`.

## [0.5.3] - 2026-04-29

### Changed
- New CamillaDSP configuration (#34).
- Beatnik OS 0.5.3 added to `beatnik-repo.json` (#35).

## [0.5.0] - 2026-03-24

### Added
- Guide for flashing the Beatnik OS image, including a note for Raspberry Pi Imager 2 (#33).
- Beatnik OS 0.5 added to `beatnik-repo.json`.

## [0.4.9] - 2026-03-17

### Changed
- Version bump.

## [0.4.8] - 2026-03-17

### Added
- `beatnik-repo.json` for installing Beatnik OS through Raspberry Pi Imager.
- CamillaDSP config for CS 77 speakers.
- CamillaDSP mixers.

### Changed
- Improved CamillaDSP default filter (#31).

### Fixed
- Wrong installation location for the controller (#32).

## [0.4.0] - 2025-12-20

### Added
- CamillaDSP setup integrated into the install shell script (#26).
- HiFiBerry Digi support (#27).
- CamillaDSP configs for Heco and Pioneer speakers and for a 2-way woofer (#16, #23).
- Snapcast version is detected from the OS and the latest release is fetched (#20, #22).
- Uninstall script (#18).
- ADC line-in docs.

### Changed
- CamillaDSP is installed before the reboot; test reboot logic removed (#28, #29).
- CamillaDSP GUI removed from the default setup.
- Clients no longer run a full system upgrade (#14, #15).

### Fixed
- Double installation and Docker setup getting stuck or crashing, with better error handling (#25).
- Permissions are applied before `docker compose up` (#17).
- Old syntax, package name and links in the CamillaDSP docs (#19, #21).
- Redirects and old repo name references.

## [0.1.0] - 2025-08-16

### Added
- CamillaDSP loopback logic and configs for a 2-way mid-woofer / tweeter setup (#13).

### Changed
- Installation guide split into server and client parts.

## [0.0.4] - 2025-08-13

### Added
- First version of the installation shell script, for server and client (#11).
- Installation guide for the shell script.
- IQaudio DAC Pro soundcard (#10).
- Hardware and software lists with component pictures.

## [0.0.3] - 2025-07-27

### Added
- Soundcard instructions for HiFiBerry Amp4 Pro, Raspberry Pi DAC+ and Raspberry Pi DigiAMP+, with sample configs.
- Architecture diagram and folder structure (#2).
- Beatnik Controller (Docker Compose) in the README (#8).
- Instructions to disable the default Shairport Sync service (#3).

### Changed
- Server, client and component names harmonized.

### Fixed
- Typos and an outdated server path. Thanks to LeokipStudent for the suggestion and to JW-CH for a README fix (#7, #9).

## [0.0.2] - 2025-06-15

### Added
- Spotify stream using librespot and AirPlay 2 integration (#1).

## [0.0.1] - 2025-05-25

### Added
- Initial README.

[Unreleased]: https://github.com/byrdsandbytes/beatnik-pi/compare/v0.8.3...HEAD
[0.8.3]: https://github.com/byrdsandbytes/beatnik-pi/compare/v0.8.2...v0.8.3
[0.8.2]: https://github.com/byrdsandbytes/beatnik-pi/compare/v0.8.1...v0.8.2
[0.8.1]: https://github.com/byrdsandbytes/beatnik-pi/compare/v.0.8.0...v0.8.1
[0.8.0]: https://github.com/byrdsandbytes/beatnik-pi/compare/v0.7.10...v.0.8.0
[0.7.10]: https://github.com/byrdsandbytes/beatnik-pi/compare/v0.7.0...v0.7.10
[0.7.0]: https://github.com/byrdsandbytes/beatnik-pi/compare/v0.6.1...v0.7.0
[0.6.1]: https://github.com/byrdsandbytes/beatnik-pi/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/byrdsandbytes/beatnik-pi/compare/v0.5.3...v0.6.0
[0.5.3]: https://github.com/byrdsandbytes/beatnik-pi/compare/v0.5.0...v0.5.3
[0.5.0]: https://github.com/byrdsandbytes/beatnik-pi/compare/v0.4.9...v0.5.0
[0.4.9]: https://github.com/byrdsandbytes/beatnik-pi/compare/v0.4.8...v0.4.9
[0.4.8]: https://github.com/byrdsandbytes/beatnik-pi/compare/v0.4.0...v0.4.8
[0.4.0]: https://github.com/byrdsandbytes/beatnik-pi/compare/v0.1.0...v0.4.0
[0.1.0]: https://github.com/byrdsandbytes/beatnik-pi/compare/v0.0.4...v0.1.0
[0.0.4]: https://github.com/byrdsandbytes/beatnik-pi/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/byrdsandbytes/beatnik-pi/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/byrdsandbytes/beatnik-pi/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/byrdsandbytes/beatnik-pi/releases/tag/v0.0.1
