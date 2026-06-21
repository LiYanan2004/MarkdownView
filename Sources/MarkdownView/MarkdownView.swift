//
//  MarkdownView.swift
//  MarkdownView
//

import SwiftUI
import Markdown

/// A view that renders markdown content.
public struct MarkdownView: View {
    private var source: MarkdownRenderingSource
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.markdownElementRenderers) private var elementRenderers
    @Environment(\.markdownFontGroup) private var fonts
    
    /// Creates a view that renders given markdown string.
    /// - Parameter text: The markdown source to render.
    public init(_ text: String) {
        self.source = .rawText(text)
    }

    /// Creates a view that renders a parsed markdown document.
    /// - Parameter document: The parsed markdown document to render.
    public init(_ document: Markdown.Document) {
        self.source = .document(document)
    }
    
    public var body: some View {
        let renderingInput = MarkdownRenderingInput(
            source: source,
            configuration: configuration,
            elementRenderers: elementRenderers
        )
        let renderer = MarkdownViewRenderer(
            configuration: renderingInput.configuration,
            elementRenderers: elementRenderers
        )
        renderer.makeBody(for: renderingInput.document)
            .erasedToAnyView()
            .font(Font(fonts.body.asPlatformFont))
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
