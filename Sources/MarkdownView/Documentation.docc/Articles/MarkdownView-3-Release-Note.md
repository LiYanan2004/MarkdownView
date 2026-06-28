# MarkdownView 3 Release Note

Learn the API changes, and new rendering features in MarkdownView 3.

## Overview

MarkdownView 3 updates the rendering API around public text-based rendering, continuous text selection, and improved streaming content rendering performance. The release also removes the broad `MarkdownViewStyle` compatibility layer in favor of dedicated SwiftUI style modifiers for individual Markdown components.

## Breaking API changes

Review these changes before updating a package that uses MarkdownView 2.

- `MarkdownViewStyle` and `markdownViewStyle(_:)` have been removed.
  - If you need a combination, use SwiftUI's `ViewModifier`.
- `MarkdownContent` has been removed from the public rendering API.
  - Pass markdown strings directly to ``MarkdownView`` and ``MarkdownText``.
  - Use ``MarkdownReader`` when multiple views should share one parsed result.
- ``MarkdownReader`` now passes ``MarkdownParseResult`` to its content builder.
  - Pass that result to ``MarkdownView``, ``MarkdownText``, or ``MarkdownTableOfContentReader`` when child views need shared parsed content.
- ``MarkdownView`` now accepts ``MarkdownParseResult`` for parsed input.
  - Replace `MarkdownView(markdownContent)` with `MarkdownView(parseResult)` inside a ``MarkdownReader`` content builder.
- `MarkdownTableOfContent` has been renamed to ``MarkdownTableOfContentReader``.
  - A deprecated typealias keeps existing call sites compiling while you migrate to the new name.
- ``MarkdownTableOfContentReader`` now passes `[Markdown.Heading]` to its content builder.
  - If you need a stable identifier for `ForEach`, iterate over `headings.indices` or another identifier you own.
- ``MarkdownFontGroup`` now uses ``CustomCTFontConvertible`` values.
  - Return platform fonts, `CTFont`, or another ``CustomCTFontConvertible`` type from custom font groups if the group can also be attached to ``MarkdownText``.
- The minimum supported platforms are now macOS 13, iOS 16, tvOS 16, and watchOS 9.

## New features

### ``MarkdownText``

Use ``MarkdownText`` to render Markdown as text content on iOS and macOS.

```swift
MarkdownText("Hello **MarkdownText**")
    .markdownLinksUnderlined()
```

`MarkdownText` uses a platform-specific text view to render its content. Depending on API availability, you might need to use `font(_:for:)` with platform fonts or `CTFont` instead of SwiftUI's `Font`. For more information, see [Font configuration](#font-configuration).

### ``MarkdownTableOfContentReader``

Use ``MarkdownTableOfContentReader`` to derive a table of contents from a parsed markdown result.

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

``MarkdownTableOfContentReader`` conforms to `Equatable`. You can add `.equatable()` when the rendered content depends only on the parsed `Markdown.Document` and the derived headings, so SwiftUI can skip recomputing the view body when document identity stays the same.

### ``StreamingMarkdownReader``

Use ``StreamingMarkdownReader`` with ``StreamingMarkdownSource`` when markdown arrives continuously.

```swift
let markdownSource = StreamingMarkdownSource()

StreamingMarkdownReader(markdownSource) { parseResult in
    MarkdownView(parseResult)
}
```

Update `markdownSource.text` as new content arrives. Call `markdownSource.finishStreaming()` when the stream is complete.

### Link underlines

Use `markdownLinksUnderlined(_:)` to control underline styling for links.

```swift
MarkdownView(markdown)
    .markdownLinksUnderlined()
```

### Font configuration

MarkdownView 3 adds ``CustomCTFontConvertible`` support for component fonts. You can pass platform fonts directly when you need consistent behavior on current deployment targets.

If you continue using ``MarkdownView``, no changes are needed. If you switch to ``MarkdownText`` and also support older OS releases where SwiftUI `Font` integration is limited, use another ``CustomCTFontConvertible``-conforming type instead.

```swift
MarkdownView(markdown)
    .font(PlatformFont.preferredFont(forTextStyle: .title1), for: .h1)
```
