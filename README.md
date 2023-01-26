# MarkdownView

MarkdownView is a Swift Package for rendering Markdown natively in SwiftUI.

Thanks to [apple/swift-markdown](https://github.com/apple/swift-markdown), it can fully compliant with the [CommonMark Spec](https://spec.commonmark.org/current/).

Here is a preview :)

![](Images/overall.jpeg)

> `MarkdownView` is still in beta. 
> There might have some API changes in the future.

# Supported Platforms

You can use MarkdownView in the following platforms:

* macOS 12.0+
* iOS 15.0+
* tvOS 15.0+

# Features

- Fully compliant with CommonMark
- **SVG rendering** support
-  Highly **Customizable** and **Extensible**
    - Fonts
    - Code Highlighter Themes
    - Tint Colors
    - Block Directives
    - Custom Images
-  Fully Native SwiftUI implementations

# Getting started

You can create a `Markdown` view by providing a Markdown-formatted string.

```swift
MarkdownView(text: "This is the Apple's **newly published** [swift-markdown](https://github.com/apple/swift-markdown)")
```

![](Images/bold_and_links.jpeg)

If your Markdown have check boxes, you can provide a `Binding` string.

```swift
@State var text = """
- [x] Write the press release
- [ ] Update the website
- [ ] Contact the media
"""
```

```swift
MarkdownView(text: $text)
```   
![](Images/checkbox.jpeg)

> For more information, Check out [Documentation](https://liyanan2004.github.io/MarkdownView/documentation/markdownview/)

# Further Customization

## Font

You can set custom fonts or change text styles.

```swift
MarkdownView(text: "# H1 title")
    .font(.largeTitle.weight(.black), for: .h1)
```

![](/Images/font.jpeg)

## Tint

Default tint color for code blocks and block quotes is the accent color.

You can customize them explicitly.

```swift
MarkdownView(text: "> Quote and `inline code`")
    .tint(.pink, for: .inlineCodeBlock)
```
![](/Images/tint.jpeg)

# Add Custom Providers

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
MarkdownView(text: markdownText)
    .imageProvider(CustomImageProvider(), forURLScheme: "my-image")
```

The implementation of the block directive is exactly the same way.

# Todos

- [ ] watchOS support. (specifically watchOS 7.0+)
- [x] Table support for iOS 15.0, macOS 12.0 and tvOS 15.0.
- [x] Add support for font size adjustments using SwiftUI built-in `.font(_:)` modifier.
- [x] Built-in image providers improvements.

# Swift Package Manager

In your `Package.swift` Swift Package Manager manifest, add the following dependency to your `dependencies` argument:

```swift
.package(url: "https://github.com/LiYanan2004/MarkdownView.git", .branch("main")),
```

Add the dependency to any targets you've declared in your manifest:

```swift
.target(name: "MyTarget", dependencies: ["MarkdownView"]),
```

# Similar Projects

- [MarkdownUI](https://github.com/gonzalezreal/MarkdownUI)

# Dependencies

- [apple/swift-markdown](https://github.com/apple/swift-markdown): Parse documents
- [SVGKit/SVGKit](https://github.com/SVGKit/SVGKit): Convert SVG to UIImage/NSImage
