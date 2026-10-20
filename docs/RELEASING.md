# Releasing HTML2MD

HTML2MD ships as a SwiftPM library. The release workflow uses
`openclaw/release-workflows/.github/workflows/release-source.yml@v1` to publish
GitHub Releases with the exact dated changelog section, frozen-commit source ZIP
and tar archives, an asset inventory, and SHA-256 checksums. There is no npm,
Homebrew binary, or Sparkle publication.

CI and release verification run on `xcode-27` with Xcode 27, keeping the package
and example's macOS 14 deployment target explicit.

## Release signing key

Releases are signed with an SSH key that never leaves the maintainer's machine.
Actions only verify signatures against the frozen policy file in the repository.

| Item | Value |
|---|---|
| Private key | `~/.ssh/html2md_release_ed25519` |
| Passphrase | macOS keychain, service `html2md-release-signing` |
| Askpass helper | `~/.ssh/html2md-askpass.sh` |
| Policy file | `.github/release-allowed-signers` |
| Fingerprint | `SHA256:Ts+9/jInsOGsXHWfwmsWCmU2tPCtx/izLhskv67EWAo` |

The policy file lists one principal, `sham435@gmail.com`, which must match the
email in the tag's identity. The tag is created with `gpg.format = ssh` and
`user.signingkey` pointing at the public key.

Recover the passphrase with:

```sh
security find-generic-password -a sham435 -s "html2md-release-signing" -w
```

Register the public key on GitHub (Settings → SSH and GPG keys → "Signing keys")
so published tags show a verified badge. The API needs the
`admin:ssh_signing_key` scope:

```sh
gh auth refresh -h github.com -s admin:ssh_signing_key
gh api -X POST user/ssh_signing_keys \
  -f title="HTML2MD release signing" \
  -f key="$(cat ~/.ssh/html2md_release_ed25519.pub)"
```

The `main` branch must be protected; the workflow refuses to publish otherwise.
Protection is configured to allow direct pushes while blocking force pushes and
deletions.

## Prepare and rehearse

Update `VERSION` and finalize exactly one `## X.Y.Z - YYYY-MM-DD` (brackets around
the version are also accepted) section in `CHANGELOG.md`. Keep `Unreleased` above it.

Merge the preparation PR and wait for every push CI check on that exact protected
`main` commit to pass. Rehearse from `main`:

```sh
gh workflow run release.yml --repo sham435/html2md0001 --ref main -f version=X.Y.Z -F dry_run=true
```

Dispatch defaults to `dry_run: true`. It builds and tests the package, validates
version and dated notes, and independently verifies frozen source archives without
creating tags or releases. Use the current `VERSION`, including for an already
released version: a rehearsal always tests current protected `main`.

## Publish

Create an SSH-signed annotated `vX.Y.Z` tag on the verified commit, using the release
key authorized by `.github/release-allowed-signers`, and push that tag. The workflow
requires that exact commit's green push CI and an unchanged signed tag. Signing
key custody stays outside Actions; live dispatch also requires an existing signed
tag. Never move a tag or republish an existing version.

`scripts/release.sh` performs the whole local flow — it checks `VERSION` against
the dated changelog section, refuses a dirty tree or an existing tag, requires
`HEAD` to be the `origin/main` head, creates the signed annotated tag, verifies it
against the policy file, and optionally pushes it:

```sh
./scripts/release.sh --dry-run   # checks only
./scripts/release.sh             # create and verify the signed tag
./scripts/release.sh --push      # also push the tag
```

Then dispatch the workflow for real, with `dry_run: false`:

```sh
gh workflow run release.yml --repo sham435/html2md0001 --ref main -f version=X.Y.Z -F dry_run=false
```

Verify the successful workflow, published notes, source archives, inventory and
checksums. Keep the next `Unreleased` section ready for subsequent changes.
The workflow replaces manual `gh release create`; there is no local publish path.

Existing unprefixed tags remain valid for SwiftPM consumers. New releases use `vX.Y.Z`; do not recreate or move historical tags.
