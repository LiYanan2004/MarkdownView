//
//  StreamingMarkdownRenderCoordinator.swift
//  MarkdownView
//

@MainActor
final class StreamingMarkdownRenderCoordinator {
    private let renderInterval: Duration

    private var renderTask: Task<Void, Never>?
    private var pendingRequest: MarkdownParseRequest?
    private var parsedResult: MarkdownParseResult?
    private var renderHandler: (@MainActor (MarkdownParseResult) -> Void)?

    init(renderInterval: Duration = .milliseconds(50)) {
        self.renderInterval = renderInterval
    }

    @MainActor deinit {
        cancel()
    }
    
    func submit(
        _ request: MarkdownParseRequest,
        onRender: @escaping @MainActor (MarkdownParseResult) -> Void
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

    func reset() {
        cancel()
        parsedResult = nil
        renderHandler = nil
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

    private func render(_ request: MarkdownParseRequest) async {
        let previousState = self.parsedResult
        let parseTask = Task.detached(priority: .userInitiated) {
            MarkdownDocumentParser.parse(
                request,
                previousState: previousState
            )
        }
        let parseResult = await withTaskCancellationHandler {
            await parseTask.value
        } onCancel: {
            parseTask.cancel()
        }
        guard Task.isCancelled == false else {
            return
        }

        self.parsedResult = parseResult
        renderHandler?(parseResult)
    }
}
