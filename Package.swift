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
        .library(name: "MarkdownPresentation", targets: ["MarkdownPresentation"]),
        .library(name: "MarkdownViewConverter", targets: ["MarkdownViewConverter"]),
        .library(name: "MarkdownTextConverter", targets: ["MarkdownTextConverter"]),
        .library(name: "MarkdownMathPlugin", targets: ["MarkdownMathPlugin"]),
    ],
    traits: [
        "LaTeX",
        .default(enabledTraits: ["LaTeX"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-markdown.git", from: "0.5.0"),
        .package(url: "https://github.com/raspu/Highlightr.git", from: "2.2.1"),
        .package(url: "https://github.com/colinc86/LaTeXSwiftUI.git", from: "1.5.0"),
        .package(url: "https://github.com/LiYanan2004/RichText.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "MarkdownRenderingEssentials",
            dependencies: [
                .product(
                    name: "Markdown",
                    package: "swift-markdown"
                ),
            ]
        ),
        .target(
            name: "MarkdownPresentation",
            dependencies: [
                "MarkdownMathPlugin",
                "MarkdownRenderingEssentials",
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
                    name: "LaTeXSwiftUI",
                    package: "LaTeXSwiftUI",
                    condition: .when(platforms: [.iOS, .macOS], traits: ["LaTeX"])
                ),
            ]
        ),
        .target(
            name: "MarkdownTextConverter",
            dependencies: [
                "MarkdownMathPlugin",
                "MarkdownPresentation",
                "MarkdownRenderingEssentials",
                .product(
                    name: "Markdown",
                    package: "swift-markdown"
                ),
                .product(
                    name: "LaTeXSwiftUI",
                    package: "LaTeXSwiftUI",
                    condition: .when(platforms: [.iOS, .macOS], traits: ["LaTeX"])
                ),
                .product(
                    name: "RichText",
                    package: "RichText",
                    condition: .when(platforms: [.iOS, .macOS])
                ),
                .product(
                    name: "Highlightr",
                    package: "Highlightr",
                    condition: .when(platforms: [.iOS, .macOS])
                ),
            ]
        ),
        .target(
            name: "MarkdownMathPlugin",
            dependencies: [
                .product(
                    name: "Markdown",
                    package: "swift-markdown"
                ),
            ]
        ),
        .target(
            name: "MarkdownViewConverter",
            dependencies: [
                "MarkdownMathPlugin",
                "MarkdownPresentation",
                "MarkdownRenderingEssentials",
                .product(
                    name: "Markdown",
                    package: "swift-markdown"
                ),
            ]
        ),
        .target(
            name: "MarkdownView",
            dependencies: [
                "MarkdownRenderingEssentials",
                "MarkdownMathPlugin",
                "MarkdownPresentation",
                "MarkdownViewConverter",
                .target(
                    name: "MarkdownTextConverter",
                    condition: .when(platforms: [.iOS, .macOS])
                ),
                .product(
                    name: "RichText",
                    package: "RichText",
                    condition: .when(platforms: [.iOS, .macOS])
                ),
                .product(
                    name: "LaTeXSwiftUI",
                    package: "LaTeXSwiftUI",
                    condition: .when(platforms: [.iOS, .macOS], traits: ["LaTeX"])
                ),
            ]
        ),
        .testTarget(
            name: "MarkdownViewTests",
            dependencies: [
                "MarkdownView",
                "MarkdownMathPlugin",
                "MarkdownTextConverter",
                "MarkdownViewConverter",
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
