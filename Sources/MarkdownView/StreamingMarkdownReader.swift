//
//  StreamingMarkdownReader.swift
//  MarkdownView
//

import Markdown
import SwiftUI
import Combine

/// A markdown reader that incrementally parse the input string and build the content from its content builder.
public struct StreamingMarkdownReader<Content: View>: View {
    private var sourceText: String
    private let content: (Markdown.Document) -> Content

    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.markdownElementRenderers) private var elementRenderers

    @StateObject private var renderCoordinator = RenderCoordinator()

    public init(
        _ text: String,
        @ViewBuilder content: @escaping (Markdown.Document) -> Content
    ) {
        self.sourceText = text
        self.content = content
    }

    public var body: some View {
        let parsingRequest = ParsingRequest(
            sourceText: sourceText,
            configuration: configuration,
            parsesBlockDirectives: elementRenderers.contains(where: { $0.blockDirective != nil })
        )

        content(currentDocument)
            .environment(\.markdownRendererConfiguration, renderCoordinator.renderedSnapshot?.configuration ?? configuration)
            .background {
                RequestObserver(
                    request: parsingRequest,
                    onUpdate: { request in
                        renderCoordinator.renderQueue.send(request)
                    }
                )
            }
            .onDisappear {
                renderCoordinator.cancel()
            }
    }
}

fileprivate extension StreamingMarkdownReader {
    var currentDocument: Markdown.Document {
        renderCoordinator.renderedSnapshot?.document ?? Markdown.Document(parsing: "")
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
    @MainActor
    final class RenderCoordinator: ObservableObject {
        @Published private(set) var renderedSnapshot: RenderedSnapshot?

        var renderQueue = PassthroughSubject<ParsingRequest, Never>()
        private var cancallables: Set<AnyCancellable> = []

        init() {
            renderQueue
                .throttle(
                    for: RunLoop.SchedulerTimeType.Stride(1.0 / 20.0),
                    scheduler: RunLoop.main,
                    latest: true
                )
                .sink { [weak self] request in
                    self?.render(request)
                }
                .store(in: &cancallables)
        }

        @MainActor deinit {
            cancel()
        }

        func cancel() {
            cancallables.forEach({ $0.cancel() })
        }

        private func render(_ request: ParsingRequest) {
            let incrementalParser = MarkdownIncrementalParser()
            let parseResult = incrementalParser.parse(
                sourceText: request.sourceText,
                configuration: request.configuration,
                parsesBlockDirectives: request.parsesBlockDirectives,
                previousState: renderedSnapshot?.incrementalParsingState
            )
            renderedSnapshot = RenderedSnapshot(
                request: request,
                renderingInput: parseResult.renderingInput,
                processedSourceText: parseResult.processedSourceText,
                rootBlockRanges: parseResult.rootBlockRanges,
                processedRootBlockRanges: parseResult.processedRootBlockRanges
            )
        }
    }

    struct ParsingRequest: Hashable {
        let sourceText: String
        let configuration: MarkdownRendererConfiguration
        let parsesBlockDirectives: Bool
    }

    // Both `onChange` and `task` modifier may drop some value change callbacks.
    struct RequestObserver: View {
        let request: ParsingRequest
        let onUpdate: (ParsingRequest) -> Void

        var body: some View {
            Group {
                #if canImport(AppKit)
                MacRequestObserverRepresentable(
                    request: request,
                    onUpdate: onUpdate
                )
                #elseif os(iOS) || os(tvOS) || os(visionOS)
                UIKitRequestObserverRepresentable(
                    request: request,
                    onUpdate: onUpdate
                )
                #endif
            }
            .frame(width: 0, height: 0)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
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

#if os(macOS)
private struct MacRequestObserverRepresentable<Request: Hashable>: NSViewRepresentable {
    let request: Request
    let onUpdate: (Request) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        NSView(frame: .zero)
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard context.coordinator.lastRequest != request else {
            return
        }

        context.coordinator.lastRequest = request
        onUpdate(request)
    }

    final class Coordinator {
        var lastRequest: Request?
    }
}
#elseif os(iOS) || os(tvOS) || os(visionOS)
private struct UIKitRequestObserverRepresentable<Request: Hashable>: UIViewRepresentable {
    let request: Request
    let onUpdate: (Request) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        UIView(frame: .zero)
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard context.coordinator.lastRequest != request else {
            return
        }

        context.coordinator.lastRequest = request
        onUpdate(request)
    }

    final class Coordinator {
        var lastRequest: Request?
    }
}
#endif

#Preview {
    StreamingMarkdownReader(
        """
        # Streaming

        This preview renders the latest coalesced markdown snapshot.
        """
    ) { document in
        MarkdownView(document)
    }
}
