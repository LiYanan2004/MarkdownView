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

    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.markdownElementRenderers) private var elementRenderers

    @State private var lastParsedResult: MarkdownDocumentParser.ParseResult?
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
            .environment(\.markdownRendererConfiguration, resolvedConfiguration)
            .background { parsingRequestEmitter }
            .onDisappear(perform: renderCoordinator.cancel)
    }
    
    @ViewBuilder
    private var parsingRequestEmitter: some View {
        let parsingRequest = StreamingMarkdownParsingRequest(
            sourceText: sourceText,
            configuration: configuration,
            requiresBlockDirectiveParsing: elementRenderers.contains(where: { $0.blockDirective != nil })
        )
        StreamingMarkdownRequestObserver(
            request: parsingRequest,
            onUpdate: { request in
                renderCoordinator.submit(request) { parserState in
                    lastParsedResult = parserState
                }
            }
        )
    }

    private var resolvedConfiguration: MarkdownRendererConfiguration {
        guard configuration.math.shouldRender else { return configuration }
        
        guard let mathContext = lastParsedResult?.mathContext else {
            return configuration
        }
        
        return configuration.with(\.math.context, mathContext)
    }
    
    private var currentDocument: Markdown.Document {
        lastParsedResult?.document ?? Markdown.Document(parsing: "")
    }
}

extension StreamingMarkdownReader {
    struct StreamingMarkdownRequestObserver: View {
        let request: StreamingMarkdownParsingRequest
        let onUpdate: (StreamingMarkdownParsingRequest) -> Void

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
