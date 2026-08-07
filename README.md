# MarkdownView

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FLiYanan2004%2FMarkdownView%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/LiYanan2004/MarkdownView)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FLiYanan2004%2FMarkdownView%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/LiYanan2004/MarkdownView)

Render Markdown in SwiftUI with native views, configurable styling, and extensible renderers.

Powered by [swift-markdown](https://github.com/swiftlang/swift-markdown), fully compliant with the CommonMark standard.

## Platforms

- macOS 13.0+
- iOS 16.0+
- tvOS 16.0+
- watchOS 9.0+
- visionOS 1.0+

## Highlighted Features

- Full CommonMark compliance
- Built-in SVG image support
- LaTeX math rendering
- Continuous text selection on iOS and macOS
- Extensible rendering with block directives
- Customizable block styling

## Documentation

You can view documentation on:

- [main @ Swift Package Index](https://swiftpackageindex.com/LiYanan2004/MarkdownView/main/documentation/MarkdownView)
- [main @ GitHub Pages](https://liyanan2004.github.io/MarkdownView/main/documentation/markdownview/)

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

### Render static markdown

Create a `MarkdownView` with a Markdown string.

```swift
let string = """
# MarkdownView

This is [MarkdownView](https://github.com/liyanan2004/MarkdownView).

MarkdownView renders Markdown with SwiftUI views.
"""

MarkdownView(string)
```

![](/Images/simple-rendering.png)

### Render streaming Markdown

`StreamingMarkdownReader` is optimized for rendering streaming markdown, with support for:

- scheduled document processing
- incremental parsing as new content arrives
- background document parsing

```swift
@State private var markdownSource = StreamingMarkdownSource()

StreamingMarkdownReader(markdownSource) { parseResult in
    // Use MarkdownView or MarkdownText based on your needs.
    MarkdownView(parseResult)
}
```

Create one `StreamingMarkdownSource` for each response and keep it alive for the lifetime of that stream. Update `markdownSource.text` as new chunks arrive, then call `finishStreaming()` when the stream finishes.

### Text selection

Use `MarkdownText` when text selection behavior is more important than full view-based layout.

```swift
MarkdownText("Hello **MarkdownText**")
```

`MarkdownText` is available when [RichText](https://github.com/LiYanan2004/RichText) framework is available, currently on iOS and macOS.

![](/Images/continuous-text-selection.gif)

### Render math

Enable LaTeX math rendering with `markdownMathRenderingEnabled()`.

```swift
MarkdownView("Inline math: $E = mc^2$")
    .markdownMathRenderingEnabled()
```

Both inline math and display math are supported.

Math rendering is available on iOS and macOS when the `LaTeX` trait is enabled. The trait is enabled by default.

### Customize appearances

Set a custom font for a Markdown component.

> [!NOTE]
> `MarkdownView` always respects to the `SwiftUI.Font`
>
> `MarkdownText` respects `SwiftUI.Font` only on OS 26 and later. Earlier OS versions fallbacks to the platform body font instead due to API limitations. It's recommended to use `CustomCTFontConvertible`-conforming types (e.g. `UIFont` / `NSFont`) if you need to support earlier OS versions.

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

### Share parsed content

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

### Extend rendering

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
