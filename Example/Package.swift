// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HTML2MDExample",
    platforms: [
        .macOS(.v14),
        .iOS(.v16),
    ],
    products: [
        .executable(
            name: "HTML2MDExample",
            targets: ["HTML2MDExample"]
        ),
    ],
    dependencies: [
        .package(name: "HTML2MD", path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "HTML2MDExample",
            dependencies: [
                .product(name: "HTML2MD", package: "HTML2MD"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .unsafeFlags(["-parse-as-library"]),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
