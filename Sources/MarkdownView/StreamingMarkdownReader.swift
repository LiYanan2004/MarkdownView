//
//  StreamingMarkdownReader.swift
//  MarkdownView
//

import Markdown
import SwiftUI

/// A markdown reader that incrementally parses markdown from a ``StreamingMarkdownSource`` and builds content from the latest parse result.
///
/// Keep one source instance for the lifetime of the view and pass each parsed result to a renderer.
///
/// ```swift
/// import SwiftUI
/// import MarkdownView
///
/// struct StreamingPreview: View {
///     @State private var markdownSource = StreamingMarkdownSource("# Response")
///
///     var body: some View {
///         StreamingMarkdownReader(markdownSource) { parseResult in
///             MarkdownView(parseResult)
///         }
///         .task {
///             for word in ["\n\nThis", " content", " streams", " in."] {
///                 try? await Task.sleep(for: .milliseconds(200))
///                 markdownSource.text += word
///             }
///
///             markdownSource.finishStreaming()
///         }
///     }
/// }
/// ```
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

    /// The content produced from the latest streaming parse result.
    public var body: some View {
        content(currentParseResult)
            .environment(\.markdownMathContext, lastParseResult?.mathContext)
            .onDisappear(perform: renderCoordinator.cancel)
            .task(id: ObjectIdentifier(source)) {
                renderCoordinator.reset()
                
                var latestStreamedText = source.text
                for await text in source.updates() {
                    latestStreamedText = text
                    submitMarkdown(text)
                }
                
                guard Task.isCancelled == false else { return }
                
                // Perform a full parse to make sure the content renders correctly.
                // This helps fix any potential issues caused by incremental parsing.
                renderCoordinator.reset()
                submitMarkdown(latestStreamedText)
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
        parsingStrategy: .full,
        sourceSnapshot: .init(text: "", blockRanges: []),
        processedSnapshot: .init(text: "", blockRanges: []),
        parseOptions: [],
        mathContext: nil,
        processedBlockStartLocations: []
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
