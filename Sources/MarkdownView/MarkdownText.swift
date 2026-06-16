//
//  MarkdownText.swift
//  MarkdownView
//
//  Created by Codex on 2026/6/16.
//

#if canImport(RichText)
import Markdown
import MarkdownTextConverter
import RichText
import SwiftUI

/// A text-based view that renders markdown content.
public struct MarkdownText: View {
    private var content: MarkdownContent

    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.markdownTextFonts) private var fonts

    /// Creates a text-based markdown view for the given markdown source.
    /// - Parameter text: The markdown source to render.
    public init(_ text: String) {
        self.content = MarkdownContent(raw: .plainText(text))
    }

    /// Creates a text-based markdown view for the given content.
    /// - Parameter content: The markdown content to render.
    public init(_ content: MarkdownContent) {
        self.content = content
    }

    public var body: some View {
        let processedInput = preparedRenderingInput()
        let converter = MDTextConverter(
            configuration: MarkdownTextConverter.MarkdownRendererConfiguration(
                presentationConfiguration: processedInput.configuration,
                fonts: fonts
            )
        )

        TextView {
            converter.makeTextContent(
                for: processedInput.content.parse(options: parseOptions)
            )
        }
    }
}

fileprivate extension MarkdownText {
    var parseOptions: ParseOptions {
        var parseOptions = ParseOptions()
        if configuration.math.shouldRender {
            parseOptions.insert(.parseBlockDirectives)
        }
        return parseOptions
    }

    struct RenderingInput {
        var content: MarkdownContent
        var configuration: MarkdownPresentation.MarkdownRendererConfiguration
    }

    func preparedRenderingInput() -> RenderingInput {
        let configuration = configuration
        guard configuration.math.shouldRender else {
            return RenderingInput(
                content: content,
                configuration: configuration
            )
        }

        let preprocessingResult = MDMathPreprocessor()
            .preprocessingResult(for: content.raw.text)

        return RenderingInput(
            content: MarkdownContent(raw: .plainText(preprocessingResult.markdown)),
            configuration: configuration.with(\.math.context, preprocessingResult.context)
        )
    }
}

// MARK: - Preview

let markdown = #"""
# Markdown Showcase

> A blockquote with **bold**, *italic*, and `inline code`.

## Text Formatting

This paragraph contains:

- **Bold**
- *Italic*
- ***Bold Italic***
- ~~Strikethrough~~
- `Inline code`
- <kbd>⌘K</kbd>

A link to [Apple](https://apple.com).

https://swift.org

---

## Lists

### Unordered List

- First item
- Second item
  - Nested item
    - Deeply nested item

### Ordered List

1. First
2. Second
   1. Nested
   2. Nested
3. Third

### Task List

- [x] Completed task
- [ ] Pending task

---

## Code

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, Markdown!")
    }
}
```

```json
{
  "name": "MarkdownView",
  "version": 1
}
```

---

## Tables

| Name | Language | Platform |
|------|----------|----------|
| Swift | Native | Apple |
| Rust | Systems | Cross-platform |

---

## Images

![Swift Logo](https://developer.apple.com/assets/elements/icons/swift/swift-64x64_2x.png)

---

## HTML

<a src="https://gituhub.com">Expandable Section</a>

This content is inside a details block.

---

## Footnotes

Here is a statement with a footnote.[^1]

[^1]: This is the footnote content.

---

## Nested Structures

> Quote level 1
>
> > Quote level 2
> > 
> > - Nested list
> > - Another item

---

## Emoji

😀 🚀 ✨
"""#

@available(iOS 17.0, macOS 14.0, *)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
#Preview {
    ScrollView {
        MarkdownText(markdown)
            .padding()
    }
}
#endif
