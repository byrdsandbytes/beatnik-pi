#!/usr/bin/env python3
"""Add (or replace) a release entry in beatnik-repo.json.

Input is the build metadata file produced by build-image.yml and attached to the
GitHub release as beatnik-os-<version>.meta.json:

    {
      "version": "v1.0.0",
      "img_size": 123, "img_sha256": "...",
      "xz_size": 45,   "xz_sha256": "..."
    }
"""

import argparse
import datetime
import json
import os
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REPO_JSON_PATH = os.path.join(REPO_ROOT, "beatnik-repo.json")
REQUIRED_KEYS = ("version", "img_size", "img_sha256", "xz_size", "xz_sha256")

DEFAULT_DESCRIPTION = "Custom Image for Beatnik Pi, a Raspberry Pi based streamer."
DEFAULT_DEVICES = ["pi5-64bit", "pi4-64bit", "pi3-64bit"]


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--meta", required=True, help="Path to the build metadata JSON")
    parser.add_argument("--release-date", help="YYYY-MM-DD, defaults to today (UTC)")
    return parser.parse_args()


def load_meta(path):
    with open(path, "r", encoding="utf-8") as f:
        meta = json.load(f)
    missing = [k for k in REQUIRED_KEYS if meta.get(k) in (None, "")]
    if missing:
        sys.exit(f"Metadata file {path} is missing: {', '.join(missing)}")
    return meta


def build_entry(meta, template, release_date):
    version = meta["version"]
    repo_slug = os.environ.get("GITHUB_REPOSITORY", "byrdsandbytes/beatnik-pi")
    return {
        "name": f"Beatnik OS {version}",
        "description": template.get("description", DEFAULT_DESCRIPTION),
        "icon": template.get("icon", ""),
        "url": f"https://github.com/{repo_slug}/releases/download/{version}/beatnik-os-{version}.img.xz",
        "extract_size": int(meta["img_size"]),
        "extract_sha256": meta["img_sha256"],
        "image_download_size": int(meta["xz_size"]),
        "image_download_sha256": meta["xz_sha256"],
        "release_date": release_date,
        "init_format": "systemd",
        "devices": template.get("devices", DEFAULT_DEVICES),
    }


def main():
    args = parse_args()
    meta = load_meta(args.meta)
    release_date = args.release_date or datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d")

    with open(REPO_JSON_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    os_list = data.get("os_list", [])
    template = os_list[0] if os_list else {}
    entry = build_entry(meta, template, release_date)

    # Re-running for the same version replaces the entry instead of duplicating it.
    data["os_list"] = [entry] + [e for e in os_list if e.get("name") != entry["name"]]

    with open(REPO_JSON_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")

    print(f"Added {entry['name']} to {REPO_JSON_PATH}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
