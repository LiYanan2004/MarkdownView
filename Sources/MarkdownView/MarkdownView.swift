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
    @Environment(\.markdownElementRenderers) private var elementRenderers
    @Environment(\.markdownFontGroup) private var fonts
    
    /// Creates a view that renders given markdown string.
    /// - Parameter text: The markdown source to render.
    public init(_ text: String) {
        self.content = MarkdownContent(raw: .plainText(text))
    }
    
    /// Creates an instance that renders from a ``MarkdownContent`` .
    /// - Parameter content: The ``MarkdownContent`` to render.
    public init(_ content: MarkdownContent) {
        self.content = content
    }
    
    public var body: some View {
        let processedInput = preparedRenderingInput()
        let renderer = MarkdownViewRenderer(
            configuration: processedInput.configuration,
            elementRenderers: elementRenderers
        )
        return renderer.makeBody(
            for: processedInput.content,
            parseOptions: parseOptions(for: elementRenderers)
        )
        .erasedToAnyView()
        .font(Font(fonts.body.asPlatformFont))
    }
}

fileprivate extension MarkdownView {
    func parseOptions(for elementRenderers: [MarkdownElementRendererRegistration]) -> ParseOptions {
        var parseOptions = ParseOptions()
        if elementRenderers.contains(where: { $0.blockDirective != nil }) {
            parseOptions.insert(.parseBlockDirectives)
        }
        return parseOptions
    }
    
    struct RenderingInput {
        var content: MarkdownContent
        var configuration: MarkdownPresentation.MarkdownRendererConfiguration
    }

    func preparedRenderingInput() -> RenderingInput {
        let configuration = configuration
        guard configuration.math.shouldRender else {
            return RenderingInput(
                content: content,
                configuration: configuration
            )
        }

        let preprocessingResult = MDMathPreprocessor()
            .preprocessingResult(
                for: content.raw.text,
                includesInlineMath: Self.includesInlineMath
            )

        return RenderingInput(
            content: MarkdownContent(raw: .plainText(preprocessingResult.markdown)),
            configuration: configuration.with(\.math.context, preprocessingResult.context)
        )
    }

    static var includesInlineMath: Bool {
        #if canImport(LaTeXSwiftUI)
        true
        #else
        false
        #endif
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
