//
//  MarkdownView.swift
//  MarkdownView
//

import SwiftUI
import Markdown

/// A view that renders markdown content.
public struct MarkdownView: View {
    private var content: MarkdownContent
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.markdownMathContext) private var mathContext
    @Environment(\.markdownElementRenderers) private var elementRenderers
    @Environment(\.markdownFontGroup) private var fonts
    
    /// Creates a view that renders given markdown string.
    /// 
    /// - Parameter text: The markdown source to render.
    public init(_ text: String) {
        self.content = .rawText(text)
    }

    /// Creates a view that renders a parsed markdown result.
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
        
        MarkdownViewRenderer(
            configuration: configuration,
            mathContext: parseResult.mathContext,
            elementRenderers: elementRenderers
        )
        .makeBody(for: parseResult.document)
        .font(fonts.body._swiftUIFont)
    }
}

// MARK: - Preview

@available(iOS 17.0, macOS 14.0, *)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
#Preview {
    ScrollView {
        MarkdownView(
            """
            # MarkdownView

            A view-based markdown renderer for SwiftUI.

            > Block quotes are useful for callouts and quoted prose.

            ## Features

            - Emphasis with **bold** and *italic* text
            - Links such as [MarkdownView](https://github.com/liyanan2004/MarkdownView)
            - Inline code like `MarkdownText("Hello")`

            ```swift
            MarkdownView("Hello **World**")
            ```
            """
        )
        .padding()
    }
    .markdownLinksUnderlined()
    .scrollBounceBehavior(.basedOnSize)
    #if os(macOS) || os(iOS)
    .textSelection(.enabled)
    #endif
}
