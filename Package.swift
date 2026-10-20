// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HTML2MD",
    platforms: [
        .macOS(.v14),
        .iOS(.v16),
        .watchOS(.v10),
        .tvOS(.v17),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "HTML2MD",
            targets: ["HTML2MD"]
        ),
    ],
    dependencies: [
        // No external dependencies - uses Apple WebKit/JavaScriptCore runtimes when available.
    ],
    targets: [
        .target(
            name: "HTML2MD",
            dependencies: [],
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "HTML2MDTests",
            dependencies: ["HTML2MD"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
