# MarkdownView


[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FLiYanan2004%2FMarkdownView%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/LiYanan2004/MarkdownView)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FLiYanan2004%2FMarkdownView%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/LiYanan2004/MarkdownView)

Display markdown content with SwiftUI.

## Overview

MarkdownView offers a super easy and highly customizable way to display markdown content in your app. 

It leverages [swift-markdown](https://github.com/swiftlang/swift-markdown) to parse markdown content, fully compliant with the [CommonMark Spec](https://spec.commonmark.org/current/).

## Supported Platforms

You can use MarkdownView in the following platforms:

* macOS 12.0+
* iOS 15.0+
* watchOS 8.0+
* tvOS 15.0+
* visionOS 1.0+

## Highlighted Features

- Fully compliant with CommonMark
- Support SVG rendering
- Support inline math rendering 
- Highly Customizable and Extensible
    - Fonts
    - Code Highlighter Themes
    - Tint Colors
    - Block Directives
    - Custom Images
- Fully Native SwiftUI implementations

## Getting started

### Displaying Contents

You can create a `Markdown` view by providing a markdown text.

```swift
let markdownText = """
# MarkdownView

This is [MarkdownView](https://github.com/liyanan2004/MarkdownView).

MarkdownView offers a super easy and highly customizable way to display markdown content in your app. It leverages swift-markdown to parse markdown content, fully compliant with the CommonMark Spec.

MarkdownView supports adavanced rendering features like SVG, Inline Math, as well as code highlighting.
"""

MarkdownView(markdownText)
```

![](/Images/simple-rendering.png)

### Customizing Appearance

You can set custom font group or change font for a specific kind of markdown markup.

```swift
MarkdownView("# H1 title")
    .font(.largeTitle.weight(.black), for: .h1)
```

![](/Images/font.jpeg)

Adding tint color for code blocks and quote blocks. Default is the accent color.

You can customize them explicitly.

```swift
MarkdownView("> Quote and `inline code`")
    .tint(.pink, for: .inlineCodeBlock)
```

![](/Images/tint.jpeg)

### Extend Rendering

You can add your custom image providers and block directive providers to display your content.

To do that, first create your provider.

```swift
struct CustomImageProvider: ImageDisplayable {
    func makeImage(url: URL, alt: String?) -> some View {
        AsyncImage(url: url) {
            switch $0 {
            case .empty: ProgressView()
            case .success(let image): image.resizable()
            case .failure(let error): Text(error.localizedDescription)
            @unknown default: Text("Unknown situation")
            }
        }
    }
}
```

Then apply your provider to `MarkdownView`.

```swift
MarkdownView(markdownText)
    .imageProvider(CustomImageProvider(), forURLScheme: "my-image")
```

The implementation of the block directive is exactly the same way.

## Documentation

For more detailed documentation, check out the [documentation](https://swiftpackageindex.com/LiYanan2004/MarkdownView/main/documentation/MarkdownView) page hosted on Swift Package Index.

## Swift Package Manager

In your `Package.swift` Swift Package Manager manifest, add the following dependency to your `dependencies` argument:

```swift
.package(url: "https://github.com/LiYanan2004/MarkdownView.git", .branch("main")),
```

Add the dependency to any targets you've declared in your manifest:

```swift
.target(name: "MyTarget", dependencies: ["MarkdownView"]),
```

## Dependencies

- [apple/swift-markdown](https://github.com/apple/swift-markdown): Parsing & Visiting documents.
- [raspu/Highlightr](https://github.com/raspu/Highlightr.git): Code Highlighting.
- [colinc86/LaTeXSwiftUI](https://github.com/colinc86/LaTeXSwiftUI.git): Math Rendering.
