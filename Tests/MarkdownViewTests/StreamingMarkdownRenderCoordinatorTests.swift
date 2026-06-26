//
//  StreamingMarkdownRenderCoordinatorTests.swift
//  MarkdownView
//
//  Created by Codex on 2026/6/26.
//

import Testing

@testable import MarkdownView

@Suite("Streaming Markdown Render Coordinator")
@MainActor
struct StreamingMarkdownRenderCoordinatorTests {
    @Test("Renders latest submitted request after input stops")
    func rendersLatestSubmittedRequestAfterInputStops() async throws {
        let renderInterval: Duration = .milliseconds(100)
        let coordinator = StreamingMarkdownRenderCoordinator(renderInterval: renderInterval)
        var renderedSourceTexts: [String] = []

        defer {
            coordinator.cancel()
        }

        coordinator.submit(request("# Emoji")) { parserState in
            renderedSourceTexts.append(parserState.sourceText)
        }

        try await waitUntil {
            renderedSourceTexts.count == 1
        }
        #expect(renderedSourceTexts == ["# Emoji"])

        let finalSourceText = "😀 🚀 ✨"
        coordinator.submit(request(finalSourceText)) { parserState in
            renderedSourceTexts.append(parserState.sourceText)
        }

        try await Task.sleep(for: renderInterval + .milliseconds(100))

        #expect(renderedSourceTexts.count >= 2)
        #expect(renderedSourceTexts.last == finalSourceText)
    }
}

private func request(_ sourceText: String) -> StreamingMarkdownParsingRequest {
    StreamingMarkdownParsingRequest(
        sourceText: sourceText,
        configuration: MarkdownRendererConfiguration(),
        requiresBlockDirectiveParsing: false
    )
}

@MainActor
private func waitUntil(
    timeout: Duration = .seconds(1),
    pollInterval: Duration = .milliseconds(10),
    condition: () -> Bool
) async throws {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)

    while condition() == false {
        if clock.now >= deadline {
            break
        }
        try await Task.sleep(for: pollInterval)
    }
}
