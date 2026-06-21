// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MarkdownView",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "MarkdownView", targets: ["MarkdownView"]),
    ],
    traits: [
        "LaTeX",
        .default(enabledTraits: ["LaTeX"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-markdown.git", from: "0.5.0"),
        .package(url: "https://github.com/raspu/Highlightr.git", from: "2.2.1"),
        .package(url: "https://github.com/mgriebling/SwiftMath.git", from: "1.7.3"),
        .package(url: "https://github.com/LiYanan2004/RichText.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "MarkdownView",
            dependencies: [
                .product(
                    name: "Markdown",
                    package: "swift-markdown"
                ),
                .product(
                    name: "Highlightr",
                    package: "Highlightr",
                    condition: .when(platforms: [.iOS, .macOS])
                ),
                .product(
                    name: "SwiftMath",
                    package: "SwiftMath",
                    condition: .when(platforms: [.iOS, .macOS], traits: ["LaTeX"])
                ),
                .product(
                    name: "RichText",
                    package: "RichText",
                    condition: .when(platforms: [.iOS, .macOS])
                ),
            ]
        ),
        .testTarget(
            name: "MarkdownViewTests",
            dependencies: [
                "MarkdownView",
                .product(
                    name: "Markdown",
                    package: "swift-markdown"
                ),
                .product(
                    name: "RichText",
                    package: "RichText",
                    condition: .when(platforms: [.iOS, .macOS])
                ),
            ],
            path: "Tests/MarkdownViewTests"
        ),
    ]
)
