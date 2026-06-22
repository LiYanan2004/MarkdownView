//
//  StreamingMarkdownReader.swift
//  MarkdownView
//

import Markdown
import SwiftUI

/// A reader that coalesces markdown parsing to the next display update.
public struct StreamingMarkdownReader<Content: View>: View {
    private let sourceText: String
    private let content: (Markdown.Document) -> Content

    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.markdownElementRenderers) private var elementRenderers

    @State private var pendingRequest: ParsingRequest?
    @State private var renderedSnapshot: RenderedSnapshot?

    public init(
        _ text: String,
        @ViewBuilder content: @escaping (Markdown.Document) -> Content
    ) {
        self.sourceText = text
        self.content = content
    }

    public var body: some View {
        content(currentDocument)
            .environment(\.markdownRendererConfiguration, renderedSnapshot?.configuration ?? configuration)
            .background {
                TimelineView(.animation(paused: pendingRequest == nil)) { timelineContext in
                    Color.clear
                        .onChange(of: timelineContext.date) { _ in
                            renderPendingRequest()
                        }
                }
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
            .task(id: parsingRequest) {
                scheduleRendering(for: parsingRequest)
            }
    }
}

fileprivate extension StreamingMarkdownReader {
    var currentConfiguration: MarkdownRendererConfiguration {
        renderedSnapshot?.configuration ?? configuration
    }

    var currentDocument: Markdown.Document {
        renderedSnapshot?.document ?? Markdown.Document(parsing: "")
    }

    var parsingRequest: ParsingRequest {
        ParsingRequest(
            sourceText: sourceText,
            configuration: configuration,
            parsesBlockDirectives: elementRenderers.contains(where: { $0.blockDirective != nil })
        )
    }

    func scheduleRendering(for request: ParsingRequest) {
        guard renderedSnapshot?.request != request else {
            pendingRequest = nil
            return
        }
        pendingRequest = request
    }

    func renderPendingRequest() {
        guard let pendingRequest else {
            return
        }

        let incrementalParser = MarkdownIncrementalParser()
        let parseResult = incrementalParser.parse(
            sourceText: pendingRequest.sourceText,
            configuration: pendingRequest.configuration,
            parsesBlockDirectives: pendingRequest.parsesBlockDirectives,
            previousState: renderedSnapshot?.incrementalParsingState
        )
        renderedSnapshot = RenderedSnapshot(
            request: pendingRequest,
            renderingInput: parseResult.renderingInput,
            processedSourceText: parseResult.processedSourceText,
            rootBlockRanges: parseResult.rootBlockRanges,
            processedRootBlockRanges: parseResult.processedRootBlockRanges
        )
        self.pendingRequest = nil
    }
}

private extension StreamingMarkdownReader.RenderedSnapshot {
    var incrementalParsingState: MarkdownIncrementalParser.PreviousState {
        MarkdownIncrementalParser.PreviousState(
            sourceText: request.sourceText,
            processedSourceText: processedSourceText,
            document: document,
            configuration: request.configuration,
            mathContext: configuration.math.context,
            parsesBlockDirectives: request.parsesBlockDirectives,
            rootBlockRanges: rootBlockRanges,
            processedRootBlockRanges: processedRootBlockRanges
        )
    }
}

extension StreamingMarkdownReader {
    struct ParsingRequest: Hashable {
        let sourceText: String
        let configuration: MarkdownRendererConfiguration
        let parsesBlockDirectives: Bool
    }

    struct RenderedSnapshot {
        let request: ParsingRequest
        let document: Markdown.Document
        let configuration: MarkdownRendererConfiguration
        let processedSourceText: String
        let rootBlockRanges: [MarkdownIncrementalParser.RootBlockRange]?
        let processedRootBlockRanges: [MarkdownIncrementalParser.RootBlockRange]?

        init(
            request: ParsingRequest,
            renderingInput: MarkdownRenderingInput,
            processedSourceText: String,
            rootBlockRanges: [MarkdownIncrementalParser.RootBlockRange]?,
            processedRootBlockRanges: [MarkdownIncrementalParser.RootBlockRange]?
        ) {
            self.request = request
            self.document = renderingInput.document
            self.configuration = renderingInput.configuration
            self.processedSourceText = processedSourceText
            self.rootBlockRanges = rootBlockRanges
            self.processedRootBlockRanges = processedRootBlockRanges
        }
    }
}
