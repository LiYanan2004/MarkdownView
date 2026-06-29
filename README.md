# MarkdownView

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FLiYanan2004%2FMarkdownView%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/LiYanan2004/MarkdownView)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FLiYanan2004%2FMarkdownView%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/LiYanan2004/MarkdownView)

Render Markdown in SwiftUI with native views, configurable styling, and extensible renderers.

MarkdownView uses [swift-markdown](https://github.com/swiftlang/swift-markdown) for parsing and supports CommonMark content, tables, task lists, code blocks, images, links, block directives, and LaTeX math rendering on iOS and macOS.

## Platforms

- macOS 13.0+
- iOS 16.0+
- tvOS 16.0+
- watchOS 9.0+
- visionOS 1.0+

## Highlighted Features

- CommonMark rendering with tables, task lists, images, links, block quotes, headings, and code blocks.
- LaTeX math rendering for inline and display math on iOS and macOS.
- Syntax-highlighted code blocks with configurable light and dark Highlightr themes on iOS and macOS.
- SVG, network, asset catalog, and relative-path image rendering.
- `MarkdownText` for text-based rendering with continuous text selection on iOS and macOS.
- `MarkdownReader`, `StreamingMarkdownReader`, and `MarkdownTableOfContentReader` for sharing parsed content, streaming updates, and building navigation.
- Custom fonts, heading styles, list markers, tint colors, component spacing, block quote styles, code block styles, and table styles.
- Custom renderers for images, links, and block directives.

## Documentation

For API details and migration notes, see the [Swift Package Index documentation](https://swiftpackageindex.com/LiYanan2004/MarkdownView/main/documentation/MarkdownView).

## Getting Started

### Swift Package Manager

Add MarkdownView to your package dependencies:

```swift
.package(url: "https://github.com/LiYanan2004/MarkdownView.git", branch: "main")
```

Add the product to your target:

```swift
.target(
    name: "MyTarget",
    dependencies: ["MarkdownView"]
)
```

## Usage

### Render Markdown

Create a `MarkdownView` with a Markdown string.

```swift
let markdownText = """
# MarkdownView

This is [MarkdownView](https://github.com/liyanan2004/MarkdownView).

MarkdownView renders Markdown with SwiftUI views.
"""

MarkdownView(markdownText)
```

![](/Images/simple-rendering.png)

### Render Selectable Text

Use `MarkdownText` when text selection behavior is more important than full view-based layout.

```swift
MarkdownText("Hello **MarkdownText**")
```

`MarkdownText` is available when RichText is available, currently on iOS and macOS.

### Render Math

Enable LaTeX math rendering with `markdownMathRenderingEnabled()`.

```swift
MarkdownView("Inline math: $E = mc^2$")
    .markdownMathRenderingEnabled()
```

Math rendering is available on iOS and macOS when the package includes the default `LaTeX` trait.

Display math is also supported:

```markdown
\[
\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
\]
```

### Customize Appearance

Set a custom font for a Markdown component.

```swift
MarkdownView("# H1 title")
    .font(.largeTitle.weight(.black), for: .h1)
```

![](/Images/font.jpeg)

Set tint colors for supported components.

```swift
MarkdownView("> Quote and `inline code`")
    .tint(.pink, for: .inlineCodeBlock)
```

![](/Images/tint.jpeg)

Set table, block quote, and code block styles.

```swift
MarkdownView(markdownText)
    .markdownTableStyle(.github)
    .markdownBlockQuoteStyle(.github)
    .markdownCodeBlockStyle(.default(lightTheme: "xcode", darkTheme: "dark"))
```

Customize list rendering.

```swift
MarkdownView(markdownText)
    .markdownListIndent(18)
    .markdownUnorderedListMarker(.bullet)
```

### Share Parsed Content

Use `MarkdownReader` when multiple views need the same parse result.

```swift
MarkdownReader(markdownText) { parseResult in
    MarkdownView(parseResult)

    MarkdownTableOfContentReader(parseResult) { headings in
        ForEach(headings.indices, id: \.self) { index in
            Text(headings[index].plainText)
        }
    }
}
```

### Extend Rendering

Register custom renderers for images, links, and block directives.

```swift
struct CustomImageRenderer: MarkdownImageRenderer {
    func makeBody(configuration: Configuration) -> some View {
        AsyncImage(url: configuration.url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image.resizable()
            case .failure(let error):
                Text(error.localizedDescription)
            @unknown default:
                EmptyView()
            }
        }
    }
}
```

Apply the renderer to a view hierarchy.

```swift
MarkdownView(markdownText)
    .markdownElementRenderer(.image(CustomImageRenderer(), urlScheme: "my-image"))
```

Use the same registration API for links and block directives:

```swift
MarkdownView(markdownText)
    .markdownElementRenderer(.link(CustomLinkRenderer(), urlScheme: "app"))
    .markdownElementRenderer(.blockDirective(CustomBlockDirectiveRenderer(), name: "note"))
```

Registering another renderer with the same block directive name or URL scheme replaces the previous registration in the same view hierarchy.

## Dependencies

- [swiftlang/swift-markdown](https://github.com/swiftlang/swift-markdown): Markdown parsing and tree traversal.
- [raspu/Highlightr](https://github.com/raspu/Highlightr.git): Syntax highlighting.
- [mgriebling/SwiftMath](https://github.com/mgriebling/SwiftMath.git): LaTeX math rendering.
- [LiYanan2004/RichText](https://github.com/LiYanan2004/RichText.git): Text-based Markdown rendering.
