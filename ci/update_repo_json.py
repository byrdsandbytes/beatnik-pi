#!/usr/bin/env python3
"""Add a new release entry to beatnik-repo.json after a CI image build."""

import argparse
import json
import os
import sys

REPO_JSON_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "beatnik-repo.json")


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--version", required=True, help="Release tag, e.g. v1.0.0")
    parser.add_argument("--img-size", required=True, type=int)
    parser.add_argument("--img-sha256", required=True)
    parser.add_argument("--xz-size", required=True, type=int)
    parser.add_argument("--xz-sha256", required=True)
    parser.add_argument("--release-date", required=False, help="YYYY-MM-DD, defaults to today (UTC)")
    return parser.parse_args()


def main():
    args = parse_args()

    with open(REPO_JSON_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    os_list = data["os_list"]
    existing = os_list[0] if os_list else {}

    repo_slug = os.environ.get("GITHUB_REPOSITORY", "byrdsandbytes/beatnik-pi")
    version = args.version
    release_date = args.release_date
    if not release_date:
        import datetime
        release_date = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d")

    new_entry = {
        "name": f"Beatnik OS {version}",
        "description": existing.get("description", "Custom Image for Beatnik Pi, a Raspberry Pi based streamer."),
        "icon": existing.get("icon", ""),
        "url": f"https://github.com/{repo_slug}/releases/download/{version}/beatnik-os-{version}.img.xz",
        "extract_size": args.img_size,
        "extract_sha256": args.img_sha256,
        "image_download_size": args.xz_size,
        "image_download_sha256": args.xz_sha256,
        "release_date": release_date,
        "init_format": "systemd",
        "devices": existing.get("devices", [
            "pi5-64bit", "pi5-32bit",
            "pi4-64bit", "pi4-32bit",
            "pi3-64bit", "pi3-32bit",
            "pi2-32bit", "pi1-32bit",
        ]),
    }

    # Avoid duplicate entries if the workflow is re-run for the same version.
    os_list = [e for e in os_list if e.get("name") != new_entry["name"]]
    os_list.insert(0, new_entry)
    data["os_list"] = os_list

    with open(REPO_JSON_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")

    print(f"Added {new_entry['name']} to {REPO_JSON_PATH}")


if __name__ == "__main__":
    sys.exit(main())
