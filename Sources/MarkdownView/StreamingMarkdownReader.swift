//
//  StreamingMarkdownReader.swift
//  MarkdownView
//

import Markdown
import SwiftUI

/// A markdown reader that incrementally parses markdown from a ``StreamingMarkdownSource`` and builds content from the latest parse result.
public struct StreamingMarkdownReader<Content: View>: View {
    let source: StreamingMarkdownSource
    private let content: (MarkdownParseResult) -> Content

    @Environment(\.markdownMathContext) private var mathContext
    @Environment(\.markdownElementRenderers) private var elementRenderers
    
    @State var lastParseResult: MarkdownParseResult? // actually triggers view updates
    @State var renderCoordinator = StreamingMarkdownRenderCoordinator()

    /// Creates a reader that incrementally parses markdown from a streaming source
    /// and passes the latest parse result to `content`.
    ///
    /// - Parameters:
    ///   - source: The required markdown source that provides streaming updates.
    ///   - content: A view builder that receives the latest parse result.
    public init(
        _ source: StreamingMarkdownSource,
        @ViewBuilder content: @escaping (MarkdownParseResult) -> Content
    ) {
        self.source = source
        self.content = content
    }

    public var body: some View {
        content(currentParseResult)
            .environment(\.markdownMathContext, lastParseResult?.mathContext)
            .onDisappear(perform: renderCoordinator.cancel)
            .task(id: ObjectIdentifier(source)) {
                renderCoordinator.reset()
                
                for await text in source.updates() {
                    submitMarkdown(text)
                }
            }
            .onChange(of: parsingOptions) { options in
                submitMarkdown(source.text)
            }
    }
    
    private func submitMarkdown(_ markdown: String) {
        let request = MarkdownParseRequest(
            sourceText: markdown,
            parsingOptions: parsingOptions
        )
        renderCoordinator.submit(request) { parseResult in
            self.lastParseResult = parseResult
        }
    }
    
    private var parsingOptions: MarkdownDocumentParsingOptions {
        MarkdownDocumentParsingOptions(
            mathContext: mathContext,
            elementRenderers: elementRenderers
        )
    }
    
    private var currentParseResult: MarkdownParseResult {
        lastParseResult ?? .empty
    }
}

fileprivate extension MarkdownParseResult {
    static let empty = MarkdownParseResult(
        document: Markdown.Document(parsing: ""),
        mode: .full,
        sourceSnapshot: .init(text: "", blockRanges: []),
        processedSnapshot: .init(text: "", blockRanges: []),
        parseOptions: [],
        mathContext: nil
    )
}

#Preview {
    let markdownSource = StreamingMarkdownSource(
        """
        # Streaming

        This preview renders the latest coalesced markdown content.
        """
    )

    StreamingMarkdownReader(
        markdownSource
    ) { parseResult in
        MarkdownView(parseResult)
    }
}
