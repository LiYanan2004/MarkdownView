# ``MarkdownView``

Display markdown content with SwiftUI.

## Overview

MarkdownView offers a super easy and highly customizable way to display markdown content in your app. It leverages [swift-markdown](https://github.com/swiftlang/swift-markdown) to parse markdown content, fully compliant with the [CommonMark Spec](https://spec.commonmark.org/current/).

MarkdownView supports adavanced rendering features like SVG, Inline Math, as well as code highlighting.

## Topics

### Adaption Guide

- <doc:AdaptionGuideForMarkdownView2>

### Document Parsring

- ``MarkdownReader``
- ``MarkdownContent``

### Displaying Contents

- ``MarkdownView/MarkdownView``
- ``MarkdownTableOfContent``

### Customizing Appearances

- <doc:MarkdownViewStyle>
- <doc:MarkdownFontGroup>
- <doc:MarkdownForegroundStyleGroup>
- <doc:OrderedListMarkerProtocol>
- <doc:UnorderedListMarkerProtocol>
- ``CodeHighlighterTheme``

### Extensibility

- <doc:ImageDisplayable>
- <doc:BlockDirectiveDisplayable>
