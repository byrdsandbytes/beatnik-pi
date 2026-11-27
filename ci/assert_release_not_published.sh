#!/usr/bin/env bash
# Exit non-zero if a published (non-draft) GitHub release already exists for TAG.
#
# Uploading a new build to a published release silently swaps the image people
# download, while beatnik-repo.json still holds the old checksums - Raspberry Pi
# Imager then fails with "SHA256 mismatch". A published release is final: to ship
# a fix, tag a new version.
#
# Usage: ci/assert_release_not_published.sh <tag>
# Needs: gh, GH_TOKEN, GITHUB_REPOSITORY
set -euo pipefail

TAG="${1:?usage: $0 <tag>}"

# The releases/tags/<tag> endpoint hides drafts, so search the full list instead.
STATE=$(gh api --paginate "repos/${GITHUB_REPOSITORY}/releases" \
  --jq ".[] | select(.tag_name == \"${TAG}\") | if .draft then \"draft\" else \"published\" end" \
  | head -n1)

case "$STATE" in
  "")
    echo "No release for ${TAG} yet - OK."
    ;;
  draft)
    echo "Release ${TAG} exists as a draft - OK, its files will be replaced."
    ;;
  published)
    echo "::error::Release ${TAG} is already published. Refusing to overwrite its files," \
         "because that would break the checksums in beatnik-repo.json." \
         "Tag a new version instead (see docs/advanced/releasing.md)."
    exit 1
    ;;
esac
