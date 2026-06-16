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
        .font(fonts.body)
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
            .preprocessingResult(for: content.raw.text)

        return RenderingInput(
            content: MarkdownContent(raw: .plainText(preprocessingResult.markdown)),
            configuration: configuration.with(\.math.context, preprocessingResult.context)
        )
    }
}

// MARK: - Preview

@available(iOS 17.0, macOS 14.0, *)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
#Preview {
    ScrollView {
        MarkdownView(markdown)
    }
}

@available(iOS 17.0, macOS 14.0, *)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
#Preview {
    ScrollView {
        VStack(alignment: .leading) {
            MarkdownView("Hello ***World***. This is [MarkdownView](https://github.com/liyanan2004/MarkdownView), a view based markdown rendering view.")
            MarkdownView("""
            ## Tables
            
            | Name | Language | Platform |
            |------|----------|----------|
            | Swift | Native | Apple |
            | Rust | Systems | Cross-platform |
            """)
            MarkdownView("![Swift Logo](https://developer.apple.com/assets/elements/icons/swift/swift-64x64_2x.png)")
        }
    }
    .markdownLinksUnderlined()
    .scrollBounceBehavior(.basedOnSize)
    #if os(macOS) || os(iOS)
    .textSelection(.enabled)
    #endif
    .padding()
}
