# MarkdownView 3 Release Note

Learn the API changes, and new rendering features in MarkdownView 3.

## Overview

MarkdownView 3 updates the rendering API around public text-based rendering, shared parsed results, continuous text selection, and improved streaming content rendering performance. The release also removes the broad `MarkdownViewStyle` compatibility layer in favor of dedicated SwiftUI style modifiers for individual Markdown components.

## Breaking API changes

Review these changes before updating a package that uses MarkdownView 2.

- `MarkdownViewStyle` and `markdownViewStyle(_:)` have been removed.
  - If you need a combination, use SwiftUI's `ViewModifier`.
- `MarkdownContent` has been removed from the public rendering API.
  - Pass markdown strings directly to ``MarkdownView`` and ``MarkdownText``.
  - Use ``MarkdownReader`` when multiple views should share one parsed result.
- `MarkdownView(_ url: URL)` and `MarkdownReader(_ url: URL, contents:)` have been removed.
  - Load URL contents before creating a markdown view, then pass the loaded string to ``MarkdownView`` or ``MarkdownReader``.
- ``MarkdownReader`` now passes ``MarkdownParseResult`` to its content builder.
  - Pass that result to ``MarkdownView``, ``MarkdownText``, or ``MarkdownTableOfContentReader`` when child views need shared parsed content.
- ``MarkdownView`` now accepts ``MarkdownParseResult`` for parsed input.
  - Replace `MarkdownView(markdownContent)` with `MarkdownView(parseResult)` inside a ``MarkdownReader`` content builder.
- `MarkdownTableOfContent` has been renamed to ``MarkdownTableOfContentReader``.
  - A deprecated typealias keeps existing call sites compiling while you migrate to the new name.
- ``MarkdownTableOfContentReader`` now passes `[Markdown.Heading]` to its content builder.
  - If you need a stable identifier for `ForEach`, iterate over `headings.indices` or another identifier you own.
  - Replace explicit `MarkdownTableOfContent.MarkdownHeading` annotations with `Markdown.Heading`.
- `MarkdownTableStyleConfiguration.Table.fallback` now provides a deprecated empty compatibility view.
  - Build custom table styles from `configuration.table`, `configuration.table.header`, and `configuration.table.rows`.
  - Remove calls to `fallback.showsRowSeparators(_:)`, `fallback.verticalSpacing(_:)`, and `fallback.horizontalSpacing(_:)`.
- ``MarkdownFontGroup`` now uses ``CustomCTFontConvertible`` values.
  - Return platform fonts, `CTFont`, or another ``CustomCTFontConvertible`` type from custom font groups if the group can also be attached to ``MarkdownText``.
- Math rendering moved from LaTeXSwiftUI to SwiftMath.
  - The `LaTeX` trait still controls math rendering support on iOS and macOS.
  - Review rendered math output when your app depends on package-specific LaTeX behavior.
- The minimum supported platforms are now macOS 13, iOS 16, tvOS 16, watchOS 9, and visionOS 1.

## New features

### ``MarkdownText``

Use ``MarkdownText`` to render Markdown as text content on iOS and macOS.

```swift
MarkdownText("Hello **MarkdownText**")
    .markdownLinksUnderlined()
```

`MarkdownText` uses a platform-specific text view to render its content. Depending on API availability, you might need to use `font(_:for:)` with platform fonts or `CTFont` instead of SwiftUI's `Font`. For more information, see [Font configuration](#font-configuration).

### Font configuration

MarkdownView 3 adds ``CustomCTFontConvertible`` support for component fonts. You can pass platform fonts directly when you need consistent behavior on current deployment targets.

When you continue using ``MarkdownView``, existing font configuration continues to work. When you switch to ``MarkdownText`` and also support older OS releases where SwiftUI `Font` integration is limited, use another ``CustomCTFontConvertible``-conforming type.

```swift
MarkdownView(markdown)
    .font(PlatformFont.preferredFont(forTextStyle: .title1), for: .h1)
```

### ``StreamingMarkdownReader``

Use ``StreamingMarkdownReader`` with ``StreamingMarkdownSource`` when markdown arrives continuously. The reader coalesces rapid updates and uses incremental parsing so stable root blocks can be reused between renders.

```swift
let markdownSource = StreamingMarkdownSource()

StreamingMarkdownReader(markdownSource) { parseResult in
    MarkdownView(parseResult)
}
```

Update `markdownSource.text` as new content arrives. Call `markdownSource.finishStreaming()` when the stream is complete.

### Math rendering

Use `markdownMathRenderingEnabled(_:)` to parse and render supported LaTeX math syntax on iOS and macOS.

MarkdownView 3 recognizes inline and display math delimiters such as `$...$`, `$$...$$`, `\(...\)`, `\[...\]`, and supported `\begin{...}` environments. Math preprocessing leaves code blocks, inline code, links, images, and block directives as source text while extracting renderable math.

### Link underlines

Use `markdownLinksUnderlined(_:)` to control underline styling for links.

```swift
MarkdownView(markdown)
    .markdownLinksUnderlined()
```

### ``MarkdownTableOfContentReader``

Previously, this is called `MarkdownTableOfContent`.

Use ``MarkdownTableOfContentReader`` to derive a table of contents from a markdown string, a parsed `Markdown.Document`, or a ``MarkdownParseResult``.

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
