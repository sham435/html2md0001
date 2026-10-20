# HTML2MD 🧽 — Scrub HTML down to Markdown

[![CI](https://img.shields.io/github/actions/workflow/status/sham435/html2md0001/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/sham435/html2md0001/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/sham435/html2md0001?style=flat-square)](https://github.com/sham435/html2md0001/releases/latest)
[![Swift 6](https://img.shields.io/badge/Swift-6-orange?style=flat-square)](https://swift.org)
[![Platforms](https://img.shields.io/badge/platforms-iOS%2016%20%7C%20macOS%2014%20%7C%20visionOS%201%20%7C%20watchOS%2010%20%7C%20tvOS%2017-lightgrey?style=flat-square)](Package.swift)
[![License](https://img.shields.io/github/license/sham435/html2md0001?style=flat-square)](LICENSE)

![HTML2MD — HTML in, Markdown out](assets/banner.png)

HTML2MD is a Swift package for converting HTML strings and rendered web pages to Markdown on Apple platforms. It uses Turndown.js in a `WKWebView` by default and includes an `html-to-md` engine backed by JavaScriptCore for simpler input.

> **Fork notice**
> HTML2MD is a fork of [Demark](https://github.com/steipete/Demark) by Peter Steinberger, used under the MIT license.
> The conversion engines, options, and error model are unchanged; the package, module, and public types are renamed to `HTML2MD`.
> Upstream is tracked as the `upstream` remote, and upstream fixes are merged forward — see [Syncing with upstream](#syncing-with-upstream).

## Install

In Xcode, choose **File → Add Package Dependencies** and enter:

```text
https://github.com/sham435/html2md0001.git
```

For a `Package.swift` manifest, add the package and product dependency:

```swift
dependencies: [
    .package(url: "https://github.com/sham435/html2md0001.git", from: "1.0.0"),
]

.target(
    name: "YourTarget",
    dependencies: [.product(name: "HTML2MD", package: "html2md0001")]
)
```

HTML2MD requires Swift 6 and has no external Swift Package dependencies.

## Quick start

Call HTML2MD from an async main-actor context:

```swift
import HTML2MD

@MainActor
func convert(_ html: String) async throws -> String {
    try await HTML2MD().convertToMarkdown(html)
}

print(try await convert("<h1>Hello</h1><p>This is <strong>bold</strong>.</p>"))
```

Output:

```markdown
# Hello

This is **bold**.
```

## Choose an engine

HTML2MD exposes two bundled conversion engines:

| Engine | Runtime | Use it for |
|---|---|---|
| `.turndown` (default) | WebKit and a browser DOM | Complex or malformed HTML and configurable heading/code styles |
| `.htmlToMd` | JavaScriptCore on an internal serial queue | Simple, well-formed HTML without a web view |

The public `HTML2MD` API is main-actor isolated. If Turndown cannot complete a conversion, the default path retries the input with `html-to-md`. Both engines support custom bullet markers, skipped tags, and ignored tags; some formatting options are engine-specific.

See [Using HTML2MD](docs/usage.md) for the complete option table, engine behavior, and error model.

## Convert a web page

HTML2MD can load an HTTP or HTTPS URL in an ephemeral `WKWebView`, wait for the rendered document, and convert either the whole page or a selected element:

```swift
import HTML2MD
import Foundation

@MainActor
func convertArticle(at url: URL) async throws -> String {
    try await HTML2MD().convertToMarkdown(
        url: url,
        loadingOptions: URLLoadingOptions(contentSelector: "article")
    )
}
```

URL conversion requires WebKit and network access. Loading options cover timeouts, an additional idle delay, CSS selection, and a custom user agent; [the usage guide](docs/usage.md#web-pages) has the details.

## Platform support

The package manifest declares these deployment targets:

| Platform | Minimum | Conversion availability |
|---|---:|---|
| macOS | 14 | WebKit and JavaScriptCore engines |
| iOS | 16 | WebKit and JavaScriptCore engines |
| visionOS | 1 | WebKit and JavaScriptCore engines |
| watchOS | 10 | Package compiles; an unavailable engine throws `HTML2MDError.runtimeUnavailable` |
| tvOS | 17 | Package compiles; an unavailable engine throws `HTML2MDError.runtimeUnavailable` |

The [example app](Example/README.md) provides a native macOS/iOS interface for comparing both engines and their output.

## Contributing

Issues, feature requests, and pull requests are welcome. Keep changes focused and run the development checks before submitting a pull request.

## Development

Build and test the package:

```sh
swift build
swift test
```

The default tests do not access the network. URL-loading integration tests are opt-in with `HTML2MD_LIVE_TESTS=1 swift test --filter HTML2MDURLLoading` (the upstream `DEMARK_LIVE_TESTS` name still works). CI also checks formatting and linting and builds the example app; [the release guide](docs/RELEASING.md) lists the full matrix.

## Syncing with upstream

The fork keeps upstream's Git history reachable:

```sh
git remote -v
# origin    git@github.com:sham435/html2md0001.git
# upstream  git@github.com:steipete/Demark.git

git fetch upstream
git merge upstream/main
```

Upstream releases before the rename are published as `Demark`; this fork's first release is `HTML2MD` 1.0.0.

## Credits

HTML2MD bundles [Turndown.js](https://github.com/mixmark-io/turndown) by Dom Christie and [html-to-md](https://github.com/stonehank/html-to-md).

Originally written by Peter Steinberger as [Demark](https://github.com/steipete/Demark). Thanks to the Swift community and the WebKit team for the language and platform runtimes the package builds on.

## License

HTML2MD is available under the [MIT License](LICENSE).

- Original work — Copyright © 2026 Peter Steinberger ([Demark](https://github.com/steipete/Demark))
- Fork modifications — Copyright © 2026 sham435

The MIT terms require upstream's copyright notice to travel with the code, so it stays in place; everything else — package name, module, API, docs, tooling — is free to customize.
