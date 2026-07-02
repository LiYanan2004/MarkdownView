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
    @Test(
        "Renders the latest submitted request after input stops",
        .tags(.streaming, .rendering)
    )
    func rendersLatestSubmittedRequestAfterInputStops() async throws {
        let renderInterval: Duration = .milliseconds(100)
        let coordinator = StreamingMarkdownRenderCoordinator()
        coordinator.setRenderInterval(renderInterval)
        var renderedSourceTexts: [String] = []

        defer {
            coordinator.cancel()
        }

        coordinator.submit(
            MarkdownViewTestSupport.makeParseRequest(markdown: "# Emoji")
        ) { parseResult in
            renderedSourceTexts.append(parseResult.sourceSnapshot.text)
        }

        try await MarkdownViewTestSupport.waitUntil {
            renderedSourceTexts.count == 1
        }
        #expect(renderedSourceTexts == ["# Emoji"])

        let finalSourceText = "😀 🚀 ✨"
        coordinator.submit(
            MarkdownViewTestSupport.makeParseRequest(markdown: finalSourceText)
        ) { parseResult in
            renderedSourceTexts.append(parseResult.sourceSnapshot.text)
        }

        try await Task.sleep(for: renderInterval + .milliseconds(100))

        #expect(renderedSourceTexts.count >= 2)
        #expect(renderedSourceTexts.last == finalSourceText)
    }
}
