//
//  StreamingMarkdownRenderCoordinator.swift
//  MarkdownView
//

@MainActor
final class StreamingMarkdownRenderCoordinator {
    private let renderInterval: Duration

    private var renderTask: Task<Void, Never>?
    private var pendingRequest: StreamingMarkdownParsingRequest?
    private var renderedParserState: MarkdownDocumentParser.ParseResult?
    private var renderHandler: (@MainActor (MarkdownDocumentParser.ParseResult) -> Void)?

    init(renderInterval: Duration = .milliseconds(50)) {
        self.renderInterval = renderInterval
    }

    @MainActor deinit {
        cancel()
    }
    
    func submit(
        _ request: StreamingMarkdownParsingRequest,
        onRender: @escaping @MainActor (MarkdownDocumentParser.ParseResult) -> Void
    ) {
        renderHandler = onRender
        pendingRequest = request
        startRenderLoopIfNeeded()
    }

    func cancel() {
        renderTask?.cancel()
        renderTask = nil
        pendingRequest = nil
    }

    private func startRenderLoopIfNeeded() {
        guard renderTask == nil else { return }

        renderTask = Task { [weak self] in
            await self?.renderLoop()
        }
    }

    private func renderLoop() async {
        while Task.isCancelled == false {
            guard let request = pendingRequest else {
                finishRenderLoop()
                return
            }

            pendingRequest = nil
            await render(request)

            guard pendingRequest != nil else {
                finishRenderLoop()
                return
            }

            // `_throttle` from `swift-async-algorithms` can keep the last value pending forever on an open stream.
            //
            // This one-shot wait renders the latest request after input stops, aligning with throttle function from Combine framework.
            do {
                try await Task.sleep(for: renderInterval)
            } catch {
                return
            }
        }
    }

    private func finishRenderLoop() {
        guard Task.isCancelled == false else {
            return
        }
        renderTask = nil
    }

    private func render(_ request: StreamingMarkdownParsingRequest) async {
        let previousState = renderedParserState
        let parseTask = Task.detached(priority: .userInitiated) {
            let parseResult = MarkdownDocumentParser.parse(
                sourceText: request.sourceText,
                configuration: request.configuration,
                requiresBlockDirectiveParsing: request.requiresBlockDirectiveParsing,
                previousState: previousState
            )

            return parseResult
        }
        let parserState = await withTaskCancellationHandler {
            await parseTask.value
        } onCancel: {
            parseTask.cancel()
        }
        guard Task.isCancelled == false else {
            return
        }

        renderedParserState = parserState
        renderHandler?(parserState)
    }
}
