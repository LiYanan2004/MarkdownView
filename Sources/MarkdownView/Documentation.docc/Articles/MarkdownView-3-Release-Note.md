# MarkdownView 3 Release Note

Learn the API changes, and new rendering features in MarkdownView 3.

## Overview

MarkdownView 3 updates the rendering API around public text-based rendering, continuous text selection, and improved streaming content rendering performance. The release also removes the broad `MarkdownViewStyle` compatibility layer in favor of dedicated SwiftUI style modifiers for individual Markdown components.

## Breaking API changes

Review these changes before updating a package that uses MarkdownView 2.

- `MarkdownViewStyle` and `markdownViewStyle(_:)` have been removed.
  - If you need a combination, use SwiftUI's `ViewModifier`.
- The minimum supported platforms are now macOS 13, iOS 16, tvOS 16, and watchOS 9.

## New features

### ``MarkdownText``

Use ``MarkdownText`` to render Markdown as text content on iOS and macOS.

```swift
MarkdownText("Hello **MarkdownText**")
    .markdownLinksUnderlined()
```

`MarkdownText` uses platform specific text view to render its content. Due to the API availability, you might need to use the new `font(_:for:)` API that with platform fonts or `CTFont` instead of using SwiftUI's `Font` (reference [Font configuration](#font-configuration) for more information)

### Link underlines

Use `markdownLinksUnderlined(_:)` to control underline styling for links.

```swift
MarkdownView(markdown)
    .markdownLinksUnderlined()
```

### Font configuration

MarkdownView 3 adds ``CustomCTFontConvertible`` support for component fonts. You can pass platform fonts directly when you need consistent behavior on current deployment targets.

If you still choose to use ``MarkdownView``, no changes are needed. If you switch to ``MarkdownText`` and also support eariler OS (e.g. iOS 18, macOS Sequoia, etc.), you should switch to other ``CustomCTFontConvertible``-conforming types.

```swift
MarkdownView(markdown)
    .font(PlatformFont.preferredFont(forTextStyle: .title1), for: .h1)
```
