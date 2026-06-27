//
//  StreamingMarkdownReader.swift
//  MarkdownView
//

import Markdown
import SwiftUI

/// A markdown reader that incrementally parse the input string and build the content from its content builder.
public struct StreamingMarkdownReader<Content: View>: View {
    private var sourceText: String
    private let content: (Markdown.Document) -> Content

    @Environment(\.markdownMathContext) private var mathContext
    @Environment(\.markdownElementRenderers) private var elementRenderers

    @State private var lastRenderingOutput: MarkdownRenderingOutput?
    @State private var renderCoordinator = StreamingMarkdownRenderCoordinator()

    public init(
        _ text: String,
        @ViewBuilder content: @escaping (Markdown.Document) -> Content
    ) {
        self.sourceText = text
        self.content = content
    }

    public var body: some View {
        content(currentDocument)
            .environment(\.markdownMathContext, lastRenderingOutput?.mathContext)
            .background { parsingRequestEmitter }
            .onDisappear(perform: renderCoordinator.cancel)
    }
    
    @ViewBuilder
    private var parsingRequestEmitter: some View {
        let input = MarkdownRenderingInput(
            sourceText: sourceText,
            mathContext: mathContext,
            elementRenderers: elementRenderers
        )
        StreamingMarkdownRequestObserver(
            request: input,
            onUpdate: { input in
                renderCoordinator.submit(input) { renderingOutput in
                    lastRenderingOutput = renderingOutput
                }
            }
        )
    }
    private var currentDocument: Markdown.Document {
        lastRenderingOutput?.document ?? Markdown.Document(parsing: "")
    }
}

extension StreamingMarkdownReader {
    struct StreamingMarkdownRequestObserver: View {
        let request: MarkdownRenderingInput
        let onUpdate: (MarkdownRenderingInput) -> Void

        var body: some View {
            // Both `onChange` & `task` may drop some final value change callbacks
            // `.id(_:)` + `.onAppear(perform:)` works perfectly across all supported platforms
            Color.clear
                .onAppear { onUpdate(request) }
                .id(request)
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }
}

#Preview {
    StreamingMarkdownReader(
        """
        # Streaming

        This preview renders the latest coalesced markdown content.
        """
    ) { document in
        MarkdownView(document)
    }
}
