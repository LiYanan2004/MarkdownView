# Adapt for MarkdownView 2

Learn new features and improvements that you can get by just updating package, and how to adapt for new APIs. 

## Overview

MarkdownView 2 offers a new set of customization APIs, adds the most requested rendering capabilities, and refactored rendering code a lot.

## Breaking API Changes

> important:
> For the version offical release of Markdown 2, some of the APIs may includes a fix-it, but these will be removed starting from the second release.

- `TOCMenu` has been renamed to ``MarkdownTableOfContent``
- Rendering control APIs, such as `markdownRenderingMode(_:)` and `markdownRenderingThread(_:)` has been marked as unavailable / removed
- `MarkdownView(text:)` has been updated to `MarkdownView(_:)`
- `markdownViewRole(_:)` has been updated to ``MarkdownView/MarkdownView/markdownViewStyle(_:)``
- `markdownUnorderedListBullet(_:)` has been updated to ``MarkdownView/MarkdownView/markdownUnorderedListMarker(_:)``

## Math Rendering

MarkdownView 2 supports inline Math rendering 🎉

If you want to add math rendering support, opt-in by ``MarkdownView/MarkdownView/markdownMathRenderingEnabled(_:)`` modifier.

![Inline Math Rendering](math-rendering.png)

## MarkdownText (Currently Unavailable)

MarkdownView 2 offers a new type of View called `MarkdownText`

The main differences between MarkdownText and MarkdownView is that MarkdownText constructs view only by using Text.

By adopting `MarkdownText`, user can get better selection experience, but it does NOT support adavanced rendering such as Table, etc.

## List Marker

You can now customize list item marker for both ordered and unordered lists by creating your own type that conforms to:

- ``OrderedListMarkerProtocol``
- ``UnorderedListMarkerProtocol``

For example, you can create alternative bullet list with ease.

```swift
struct UnorderedListAlternativeBulletMarker: UnorderedListMarkerProtocol {
    func marker(listDepth: Int) -> String {
        if (listDepth + 1) % 2 == 0 {
            "◦"
        } else {
            "•"
        }
    }
}

MarkdownView(text)
    .markdownUnorderedListMarker(UnorderedListAlternativeBulletMarker())
```

![Alternative Bullet](unordered-list-alternative-bullet.png)

### MarkdownReader

MarkdownView 2 offers a reader that provides a markdown content to use across multiple views.

This reader offers a single source-of-truth for its child markdown views, and
ensures the input is only parsed once.

```swift
MarkdownReader("**Hello World**") { markdown in
    MarkdownView(markdown)
    MarkdownTableOfContent(markdown) { headings in
        // ...
    }
}
```
