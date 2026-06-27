# ``MarkdownView``

Display markdown content with SwiftUI.

## Overview

MarkdownView offers a highly customizable way to display markdown content in your app. It leverages [swift-markdown](https://github.com/swiftlang/swift-markdown) to parse markdown content, fully compliant with the [CommonMark Spec](https://spec.commonmark.org/current/).

MarkdownView supports advanced rendering features like SVG, code highlighting on iOS and macOS, and LaTeX math rendering on iOS and macOS.

On iOS and macOS, ``MarkdownText`` provides text-based rendering and continuous text selection.

## Topics

### Document Parsring

- ``MarkdownReader``
- ``StreamingMarkdownReader``

### Displaying Contents

- ``MarkdownView/MarkdownView``
- ``MarkdownText``
- ``MarkdownTableOfContentReader``

### Customizing Appearances

- <doc:MarkdownFontGroup>
- <doc:HeadingStyleGroup>
- <doc:MarkdownCodeBlockStyle>
- <doc:MarkdownBlockQuoteStyle>
- <doc:MarkdownTableStyle>
- <doc:MarkdownOrderedListMarkerProtocol>
- <doc:MarkdownUnorderedListMarkerProtocol>

### Extensibility

- <doc:MarkdownElementRenderer>
- <doc:MarkdownElementRendererRegistration>
- <doc:MarkdownImageRenderer>
- <doc:MarkdownLinkRenderer>
- <doc:MarkdownBlockDirectiveRenderer>

### Release Note

- <doc:MarkdownView-3-Release-Note>
