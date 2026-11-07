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
        "Cancellation releases objects captured by the render handler",
        .tags(.streaming, .rendering)
    )
    func cancellationReleasesCapturedObjects() async throws {
        let coordinator = StreamingMarkdownRenderCoordinator()
        weak var capturedCoordinator: StreamingMarkdownRenderCoordinator?
        var didRender = false

        do {
            let renderOwner = StreamingMarkdownRenderCoordinator()
            capturedCoordinator = renderOwner
            coordinator.submit(
                MarkdownViewTestSupport.makeParseRequest(markdown: "# Retained handler")
            ) { [renderOwner] _ in
                renderOwner.setRenderInterval(.milliseconds(100))
                didRender = true
            }
        }

        try await MarkdownViewTestSupport.waitUntil { didRender }
        #expect(capturedCoordinator != nil)

        coordinator.cancel()

        #expect(capturedCoordinator == nil)
    }

    @Test(
        "Renders a new request after cancellation",
        .tags(.streaming, .rendering)
    )
    func rendersAfterCancellation() async throws {
        let coordinator = StreamingMarkdownRenderCoordinator()
        var cancelledHandlerWasCalled = false
        var renderedSourceText: String?
        defer { coordinator.cancel() }

        coordinator.submit(
            MarkdownViewTestSupport.makeParseRequest(markdown: "# Cancelled")
        ) { _ in
            cancelledHandlerWasCalled = true
        }
        coordinator.cancel()

        let sourceText = "# Resumed"
        coordinator.submit(
            MarkdownViewTestSupport.makeParseRequest(markdown: sourceText)
        ) { parseResult in
            renderedSourceText = parseResult.sourceSnapshot.text
        }

        try await MarkdownViewTestSupport.waitUntil { renderedSourceText != nil }
        #expect(renderedSourceText == sourceText)
        #expect(cancelledHandlerWasCalled == false)
    }

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
