//
//  MarkdownText.swift
//  MarkdownView
//
//  Created by Codex on 2026/6/16.
//

#if canImport(RichText)
import RichText
import SwiftUI
import Markdown

/// A text-based view that renders markdown content.
@available(watchOS, unavailable)
@available(tvOS, unavailable)
@available(visionOS, unavailable)
public struct MarkdownText: View {
    private var content: MarkdownContent
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.markdownMathContext) private var mathContext
    @Environment(\.markdownElementRenderers) private var elementRenderers
    @Environment(\.markdownFontGroup) private var fonts
    @Environment(\.blockQuoteStyle) private var blockQuoteStyle
    @Environment(\.codeBlockStyle) private var codeBlockStyle
    @Environment(\.markdownTableStyle) private var tableStyle
    
    /// Creates a text-based markdown view for the given markdown source.
    ///
    /// - Parameter text: The markdown source to render.
    public init(_ text: String) {
        self.content = .rawText(text)
    }
    
    /// Creates a text-based markdown view for the given parsed markdown result.
    ///
    /// - Parameter parseResult: The parsed markdown result to render.
    public init(_ parseResult: MarkdownParseResult) {
        self.content = .parsedDocument(parseResult)
    }
    
    public var body: some View {
        let parseResult = content.parse(
            with: MarkdownDocumentParsingOptions(
                mathContext: mathContext,
                elementRenderers: elementRenderers
            )
        )
        
        TextView {
            MarkdownTextConverter(
                configuration: configuration,
                mathContext: parseResult.mathContext,
                elementRenderers: elementRenderers,
                fonts: fonts,
                blockQuoteStyle: blockQuoteStyle,
                codeBlockStyle: codeBlockStyle,
                tableStyle: tableStyle
            )
            .makeTextContent(for: parseResult.document)
        }
        .environment(\.markdownMathContext, parseResult.mathContext)
        .environment(\.markdownElementRenderers, elementRenderers)
        .environment(\.markdownFontGroup, fonts)
        .environment(\.blockQuoteStyle, blockQuoteStyle)
        .environment(\.codeBlockStyle, codeBlockStyle)
        .environment(\.markdownTableStyle, tableStyle)
    }
}

// MARK: - Preview

@available(iOS 17.0, macOS 14.0, *)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
@available(visionOS, unavailable)
#Preview {
    MarkdownText(
        """
        # MarkdownText

        A text-based markdown renderer for SwiftUI.

        > Block quotes are useful for callouts and quoted prose.

        ## Features

        - Emphasis with **bold** and *italic* text
        - Links such as [MarkdownView](https://github.com/liyanan2004/MarkdownView)
        - Inline code like `MarkdownText("Hello")`

        ```swift
        MarkdownText("Hello **World**")
        ```
        """
    )
    .padding()
}
#endif
