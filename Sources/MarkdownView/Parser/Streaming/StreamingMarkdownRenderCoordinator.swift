//
//  StreamingMarkdownRenderCoordinator.swift
//  MarkdownView
//

@MainActor
final class StreamingMarkdownRenderCoordinator {
    private let renderInterval: Duration

    private var renderTask: Task<Void, Never>?
    private var pendingInput: MarkdownRenderingInput?
    private var renderedParserState: MarkdownDocumentParser.ParseResult?
    private var renderHandler: (@MainActor (MarkdownRenderingOutput) -> Void)?

    init(renderInterval: Duration = .milliseconds(50)) {
        self.renderInterval = renderInterval
    }

    @MainActor deinit {
        cancel()
    }
    
    func submit(
        _ input: MarkdownRenderingInput,
        onRender: @escaping @MainActor (MarkdownRenderingOutput) -> Void
    ) {
        renderHandler = onRender
        pendingInput = input
        startRenderLoopIfNeeded()
    }

    func cancel() {
        renderTask?.cancel()
        renderTask = nil
        pendingInput = nil
    }

    private func startRenderLoopIfNeeded() {
        guard renderTask == nil else { return }

        renderTask = Task { [weak self] in
            await self?.renderLoop()
        }
    }

    private func renderLoop() async {
        while Task.isCancelled == false {
            guard let request = pendingInput else {
                finishRenderLoop()
                return
            }

            pendingInput = nil
            await render(request)

            guard pendingInput != nil else {
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

    private func render(_ input: MarkdownRenderingInput) async {
        let previousState = renderedParserState
        let parseTask = Task.detached(priority: .userInitiated) {
            MarkdownDocumentParser.parse(
                input,
                previousState: previousState
            )
        }
        let renderingOutput = await withTaskCancellationHandler {
            await parseTask.value
        } onCancel: {
            parseTask.cancel()
        }
        guard Task.isCancelled == false else {
            return
        }

        renderedParserState = renderingOutput.parseResult
        renderHandler?(renderingOutput)
    }
}
