# ``MarkdownView``

Display markdown content with SwiftUI.

## Overview

MarkdownView offers a super easy and highly customizable way to display markdown content in your app. It leverages [swift-markdown](https://github.com/swiftlang/swift-markdown) to parse markdown content, fully compliant with the [CommonMark Spec](https://spec.commonmark.org/current/).

MarkdownView supports adavanced rendering features like SVG, LaTeX math, as well as code highlighting.

On iOS and macOS, ``MarkdownText`` provides text-based rendering and continuous text selection.

## Topics

### Document Parsring

- ``MarkdownReader``
- ``MarkdownContent``

### Displaying Contents

- ``MarkdownView/MarkdownView``
- ``MarkdownText``
- ``MarkdownTableOfContent``

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
