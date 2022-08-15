# ``MarkdownView``

Rendering Markdown text natively in SwiftUI

## Overview

MarkdownView offers you a very convenient way to convert Markdown text to a single attributed View.

MarkdownView depends on [apple/swift-markdown](https://github.com/apple/swift-markdown), so it can fully compliant with the [CommonMark Spec](https://spec.commonmark.org/current/).

## Topics

### Create a Markdown View

- ``MarkdownView/MarkdownView``

### Lazy Loading

- ``MarkdownView/MarkdownView/lazyLoading(_:)``

### Image Loading

- ``MarkdownView/MarkdownView/imageHandler(_:forURLScheme:)``

- ``MarkdownImageHandler``

### Code Block Hightlight Theme

- ``MarkdownView/MarkdownView/codeBlockThemeConfiguration(using:)``

- ``CodeBlockThemeConfiguration``

### Handle Directive Markdown Syntax

- ``MarkdownView/MarkdownView/directiveBlockHandler(_:for:)``

- ``MarkdownDirectiveBlockHandler``

- ``MarkdownView/MarkdownView/disableDefaultDirectiveBlockHandler()``
