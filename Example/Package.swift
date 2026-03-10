// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MarkdownViewExample",
    platforms: [
        .macOS(.v15),
        .iOS(.v16),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2),
    ],
    products: [
        .library(
            name: "MarkdownViewExample",
            targets: ["MarkdownViewExample"]
        ),
    ],
    dependencies: [
        .package(path: "../"),
    ],
    targets: [
        .target(
            name: "MarkdownViewExample",
            dependencies: [
                "MarkdownView",
            ]
        ),
    ]
)
