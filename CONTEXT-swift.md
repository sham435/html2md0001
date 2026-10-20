# Project Context for OpenCode Agent for the stack - Swift / SwiftPM

## Tech Stack

- Swift 6 (`swift-tools-version: 6.0`, `swiftLanguageModes: [.v6]`, `StrictConcurrency` experimental feature enabled)
- SwiftPM — single library product, no external package dependencies
- WebKit (`WKWebView`) for the default Turndown engine; JavaScriptCore for the `html-to-md` engine
- swift-testing (not XCTest) for the test suite
- SwiftLint 0.65+, SwiftFormat 0.64+, `.swiftformat`/`.swiftlint.yml` at the repo root
- GitHub Actions on `xcode-27` runners (Xcode 27), `MACOSX_DEPLOYMENT_TARGET: 14.0`
- Deployment minimums: macOS 14, iOS 16, visionOS 1, watchOS 10, tvOS 17

## Official Docs

- Package Manager docs — https://docs.swift.org/swiftpm/documentation/packagemanagerdocs/
- Creating a Swift package — https://docs.swift.org/swiftpm/documentation/packagemanagerdocs/creatingswiftpackage
- Releasing and publishing a package — https://docs.swift.org/swiftpm/documentation/packagemanagerdocs/releasingpublishingapackage
- Continuous integration — https://docs.swift.org/swiftpm/documentation/packagemanagerdocs/continuousintegration
- `PackageDescription` API — https://developer.apple.com/documentation/packagedescription
- The Swift Programming Language (concurrency) — https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/
- SwiftLint — https://github.com/realm/SwiftLint · SwiftFormat — https://github.com/nicklockwood/SwiftFormat

## Project Structure

```
.
├── Package.swift                 # manifest: product HTML2MD, target HTML2MD, testTarget HTML2MDTests
├── VERSION                       # release version, e.g. 2.0.0 — must match a dated CHANGELOG section
├── README.md                     # install + quick start (public API surface lives in docs/usage.md)
├── CHANGELOG.md                  # Unreleased section on top; one dated `## X.Y.Z - YYYY-MM-DD` per release
├── LICENSE                       # MIT, keeps upstream (Peter Steinberger) + fork copyright
├── docs/
│   ├── usage.md                  # option table, engine behaviour, error model
│   └── RELEASING.md              # release flow, signing key, rehearsal + publish
├── .github/
│   ├── workflows/ci.yml          # test / lint / example on xcode-27
│   ├── workflows/release.yml     # calls openclaw/release-workflows release-source@v1
│   └── release-allowed-signers   # SSH release signing policy — one principal: sham435@gmail.com
├── scripts/
│   ├── lint.sh / swiftlint.sh / swiftformat.sh
│   └── release.sh                # creates, verifies and pushes the signed annotated tag
├── Sources/HTML2MD/
│   ├── HTML2MD.swift             # public HTML2MD type, @MainActor, HTML + URL overloads
│   ├── HTML2MDTypes.swift        # HTML2MDOptions / HTML2MDError / heading + code styles
│   ├── TurndownRuntime.swift     # Turndown.js in WKWebView
│   ├── HTMLToMdRuntime.swift     # html-to-md on a JavaScriptCore serial queue
│   ├── URLLoadingRuntime.swift   # ephemeral WKWebView navigation + extraction
│   ├── BundleResourceHelper.swift
│   └── Resources/                # turndown.min.js, html-to-md.min.js (bundled via Bundle.module)
├── Tests/HTML2MDTests/           # swift-testing suites; live URL tests opt-in
└── Example/                      # separate SwiftPM app + XcodeGen project
    ├── Package.swift             # depends on the local package by path
    ├── project.yml               # XcodeGen spec (targets HTML2MDExample-iOS / -macOS)
    └── Sources/HTML2MDExample/
```

## Key Files

| File | Purpose |
|---|---|
| `Package.swift` | Product/target names, platform minimums, resources, strict concurrency flags |
| `Sources/HTML2MD/HTML2MD.swift` | Public entry point; `@MainActor final class HTML2MD`; `convertToMarkdown(_:options:)` and `convertToMarkdown(url:options:loadingOptions:)` |
| `Sources/HTML2MD/HTML2MDTypes.swift` | `HTML2MDOptions`, `HTML2MDError`, `HTML2MDHeadingStyle`, `HTML2MDCodeBlockStyle`, `URLLoadingOptions`, `ConversionEngine` |
| `Sources/HTML2MD/TurndownRuntime.swift` | WebKit engine: bundles `turndown.min.js`, injects it, calls `turndownService.turndown(html)` |
| `Sources/HTML2MD/HTMLToMdRuntime.swift` | JavaScriptCore engine on a private serial queue; `html-to-md.min.js` |
| `Sources/HTML2MD/URLLoadingRuntime.swift` | Ephemeral `WKWebView`, navigation timeout, ready-state poll, idle delay, CSS selector extraction |
| `Sources/HTML2MD/BundleResourceHelper.swift` | Finds bundled JS across `Bundle.module`, `Bundle.main`, framework bundles |
| `Tests/HTML2MDTests/` | 62 tests in 12 suites; `HTML2MDURLLoadingTests` is skipped unless `HTML2MD_LIVE_TESTS=1` |
| `scripts/release.sh` | Release preflight → signed annotated tag → policy verification → optional push |
| `docs/usage.md` | The public option table; the README links to it instead of duplicating it |
| `.github/release-allowed-signers` | Frozen SSH signing policy; the tag's principal must match it |

## CLI Commands

- init: `swift package init --type library` (this repo was created by hand, not by the template)
- build: `swift build` · release build: `swift build -c release`
- test: `swift test` · opt-in live URL tests: `HTML2MD_LIVE_TESTS=1 swift test --filter HTML2MDURLLoading`
- run: `swift run HTML2MDExample` (from `Example/`, needs full Xcode — see Rules)
- lint: `./scripts/lint.sh` (SwiftFormat `--lint` + SwiftLint)
- format: `./scripts/swiftformat.sh` · autofix lint: `./scripts/swiftlint.sh --fix`
- release: `./scripts/release.sh --dry-run` → `--push` → `gh workflow run release.yml -f version=X.Y.Z -F dry_run=false`
- dependency: `swift package add-dependency <url> --from <version>` / `add-target-dependency`

## Rules

1. **One dated CHANGELOG section per version.** The release workflow fails with `needs exactly one dated level-two section for X.Y.Z; found N`. Upstream's Demark history keeps a `1.0.0` section, so the fork starts at `2.0.0`. Never reuse a version that already has a dated section.
2. **Tags must be full SemVer and SSH-signed.** `1.0` is not a complete semantic version to SwiftPM. The tag must be an annotated SSH-signed tag whose principal matches `.github/release-allowed-signers`, and it must peel to the frozen commit. Never move or republish a tag.
3. **The default branch must be protected** — the release workflow hard-fails with `default branch main is not protected`. Protection allows direct pushes but blocks force pushes and deletions.
4. **Sign with the fork's own key** (`~/.ssh/html2md_release_ed25519`, ED25519 `SHA256:Ts+9/jInsOGsXHWfwmsWCmU2tPCtx/izLhskv67EWAo`). The passphrase lives in the macOS keychain (service `html2md-release-signing`); `~/.ssh/html2md-askpass.sh` feeds it to `git tag -s`. The key never enters the repo or CI.
5. **Public API is `@MainActor`.** `HTML2MD` and its overloads stay main-actor isolated; the JavaScriptCore engine does its work on an internal serial queue but callers still enter through the main actor.
6. **The Turndown engine falls back to html-to-md** on failure; selecting `.htmlToMd` explicitly does not fall back. Keep that contract.
7. **Bundled JS is a resource, never downloaded.** `turndown.min.js` and `html-to-md.min.js` ship in `Resources/` and are resolved through `Bundle.module`. The package has zero external dependencies.
8. **Bullet-marker normalisation must not touch fenced code.** Normalisation skips fenced blocks, including shorter fences, mixed fence markers, and indented fence-like text; lists after the closing fence still get the requested marker.
9. **File headers are enforced.** SwiftLint's `file_header` rule requires the `// <ModuleName>` line and the `Created by <name> on <date>` line — the module line must read `// HTML2MD`.
10. **Lint parity with upstream.** After any change, `swiftformat --lint` must report 0 files and SwiftLint must not gain warnings beyond upstream's baseline (8 warnings, all pre-existing: file headers on the atacan-authored file and header-less test files, plus one attributes and one opening-brace warning).
11. **The example app needs full Xcode.** `actool` and the SwiftUI macro plugin are unavailable in CommandLineTools, so `cd Example && swift build` fails locally with `tool 'actool' requires Xcode`. This is environmental, not a code defect — CI builds it on `xcode-27`. Verify Swift changes with `swift build` and `swift test` at the package root.
12. **Upstream is tracked as `upstream`.** Merge `upstream/main` forward rather than forking the code; the rebrand touches the module, public type names, the example app, the docs and the identifiers — keep the diff focused so upstream merges stay small.
13. **Keep upstream's copyright.** MIT requires upstream's notice to stay in `LICENSE`; add the fork's line alongside it, never in place of it.
