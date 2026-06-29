# ``MarkdownView``

Display markdown content with SwiftUI.

## Overview

MarkdownView offers a highly customizable way to display markdown content in your app. It leverages [swift-markdown](https://github.com/swiftlang/swift-markdown) to parse markdown content, fully compliant with the [CommonMark Spec](https://spec.commonmark.org/current/).

MarkdownView supports advanced rendering features like SVG, code highlighting, and LaTeX math rendering.

On iOS and macOS, ``MarkdownText`` provides text-based rendering and continuous text selection.

## Topics

### Parsing documents

- ``MarkdownReader``
- <doc:StreamingMarkdownReader>
- <doc:StreamingMarkdownSource>
- <doc:MarkdownParseResult>
- <doc:MarkdownDocumentParsingOptions>

### Displaying content

- ``MarkdownView/MarkdownView``
- ``MarkdownText``
- ``MarkdownTableOfContentReader``
- ``MarkdownTableOfContent``

### Customizing appearances

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

### Release notes

- <doc:MarkdownView-3-Release-Note>
