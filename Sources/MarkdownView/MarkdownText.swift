//
//  MarkdownText.swift
//  MarkdownView
//
//  Created by Codex on 2026/6/16.
//

#if canImport(RichText)
import Markdown
import MarkdownPresentation
import MarkdownTextConverter
import RichText
import SwiftUI

/// A text-based view that renders markdown content.
public struct MarkdownText: View {
    private var content: MarkdownContent

    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.markdownElementRenderers) private var elementRenderers
    @Environment(\.markdownFontGroup) private var fonts
    @Environment(\.blockQuoteStyle) private var blockQuoteStyle
    @Environment(\.codeBlockStyle) private var codeBlockStyle
    @Environment(\.markdownTableStyle) private var tableStyle

    /// Creates a text-based markdown view for the given markdown source.
    /// - Parameter text: The markdown source to render.
    public init(_ text: String) {
        self.content = MarkdownContent(raw: .plainText(text))
    }

    /// Creates a text-based markdown view for the given content.
    /// - Parameter content: The markdown content to render.
    public init(_ content: MarkdownContent) {
        self.content = content
    }

    public var body: some View {
        let processedInput = preparedRenderingInput()
        let converter = MDTextConverter(
            configuration: processedInput.configuration,
            elementRenderers: elementRenderers,
            fonts: fonts,
            blockQuoteStyle: blockQuoteStyle,
            codeBlockStyle: codeBlockStyle,
            tableStyle: tableStyle
        )

        TextView {
            converter.makeTextContent(
                for: processedInput.content.parse(options: parseOptions)
            )
        }
        .environment(\.markdownRendererConfiguration, processedInput.configuration)
        .environment(\.markdownElementRenderers, elementRenderers)
        .environment(\.markdownFontGroup, fonts)
        .environment(\.blockQuoteStyle, blockQuoteStyle)
        .environment(\.codeBlockStyle, codeBlockStyle)
        .environment(\.markdownTableStyle, tableStyle)
    }
}

fileprivate extension MarkdownText {
    var parseOptions: ParseOptions {
        var parseOptions = ParseOptions()
        if configuration.math.shouldRender
            || elementRenderers.contains(where: { $0.blockDirective != nil }) {
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
