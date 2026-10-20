#!/bin/bash

# Release helper for HTML2MD
# Creates a signed annotated tag for the current VERSION, verifies it against
# .github/release-allowed-signers, and optionally pushes it and dispatches the
# release workflow.
#
# Usage:
#   ./scripts/release.sh            # verify + create the signed tag locally
#   ./scripts/release.sh --push     # also push the tag
#   ./scripts/release.sh --dry-run  # run every check, create nothing
#
# The signing key defaults to ~/.ssh/html2md_release_ed25519. Its passphrase
# is read from the macOS keychain through ~/.ssh/html2md-askpass.sh.

set -euo pipefail

cd "$(dirname "$0")/.."

PUSH=false
DRY_RUN=false

for arg in "$@"; do
    case "$arg" in
        --push) PUSH=true ;;
        --dry-run) DRY_RUN=true ;;
        -h | --help)
            sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            exit 2
            ;;
    esac
done

VERSION="$(tr -d '[:space:]' < VERSION | sed 's/^v//')"
TAG="v${VERSION}"
ALLOWED_SIGNERS=".github/release-allowed-signers"
SIGNING_KEY="${HTML2MD_SIGNING_KEY:-$HOME/.ssh/html2md_release_ed25519}"
ASKPASS="${HTML2MD_ASKPASS:-$HOME/.ssh/html2md-askpass.sh}"

fail() {
    echo "❌ $1" >&2
    exit 1
}

echo "🔖 Releasing HTML2MD ${VERSION} (${TAG})"
echo

# --- Preflight checks -------------------------------------------------------

[[ -n "$VERSION" ]] || fail "VERSION is empty"
[[ -f "$ALLOWED_SIGNERS" ]] || fail "$ALLOWED_SIGNERS is missing"
[[ -s "$ALLOWED_SIGNERS" ]] || fail "$ALLOWED_SIGNERS is empty"
[[ -f "$SIGNING_KEY" ]] || fail "signing key $SIGNING_KEY is missing"

if ! grep -qE "^##+ \[?${VERSION}\]? - [0-9]{4}-[0-9]{2}-[0-9]{2}" CHANGELOG.md; then
    fail "CHANGELOG.md has no dated section for ${VERSION}"
fi

if [[ -n "$(git status --porcelain)" ]]; then
    fail "working tree is not clean"
fi

if git rev-parse -q --verify "refs/tags/${TAG}" > /dev/null; then
    fail "tag ${TAG} already exists locally; never move or republish a tag"
fi

git fetch --quiet origin || fail "could not fetch origin"
if git ls-remote --exit-code --tags origin "refs/tags/${TAG}" > /dev/null 2>&1; then
    fail "tag ${TAG} already exists on origin; never move or republish a tag"
fi

if [[ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ]]; then
    fail "HEAD is not the origin/main head; push the release commit first"
fi

echo "✅ VERSION ${VERSION} matches a dated CHANGELOG section"
echo "✅ working tree clean, HEAD matches origin/main"
echo "✅ signing key: ${SIGNING_KEY}"
echo "   $(ssh-keygen -lf "${SIGNING_KEY}.pub" | awk '{print $2}')"
echo

if [[ "$DRY_RUN" == true ]]; then
    echo "🧪 Dry run: all checks passed, no tag created."
    exit 0
fi

# --- Create the signed annotated tag ----------------------------------------

export SSH_ASKPASS="$ASKPASS"
export SSH_ASKPASS_REQUIRE=force
export GIT_ASKPASS="$ASKPASS"

git tag -s -u "$SIGNING_KEY" -m "Release ${TAG}" "$TAG"

# --- Verify against the frozen allowed-signers policy ------------------------

git -c gpg.format=ssh -c gpg.ssh.allowedSignersFile="$ALLOWED_SIGNERS" verify-tag "$TAG" \
    || fail "tag signature did not verify against ${ALLOWED_SIGNERS}"

echo
echo "✅ Signed tag ${TAG} created and verified"
git show --no-patch --format='   %H%n   %s' "$TAG"

if [[ "$PUSH" == true ]]; then
    git push origin "$TAG"
    echo "✅ Pushed ${TAG} to origin"
    echo
    echo "🚀 Rehearse the release workflow:"
    echo "   gh workflow run release.yml --repo sham435/html2md0001 --ref main -f version=${VERSION} -F dry_run=true"
else
    echo
    echo "ℹ️  Tag not pushed. Run './scripts/release.sh --push' when ready."
fi
