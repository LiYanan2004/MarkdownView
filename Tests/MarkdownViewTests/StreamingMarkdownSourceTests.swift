//
//  StreamingMarkdownSourceTests.swift
//  MarkdownView
//
//  Created by Codex on 2026/6/28.
//

import Testing

@testable import MarkdownView

@Suite("Streaming Markdown Source")
@MainActor
struct StreamingMarkdownSourceTests {
    @Test(
        "Delivers the latest text to a new subscription after cancellation",
        .tags(.streaming)
    )
    func newSubscriptionReceivesLatestTextAfterPreviousSubscriptionIsCancelled() async throws {
        let source = StreamingMarkdownSource("Initial")
        var firstSubscriptionValues: [String] = []

        let firstSubscription = Task {
            for await text in source.updates() {
                firstSubscriptionValues.append(text)
            }
        }

        try await MarkdownViewTestSupport.waitUntil {
            firstSubscriptionValues == ["Initial"]
        }

        firstSubscription.cancel()
        source.text = "Updated while hidden"

        var secondSubscriptionValues: [String] = []
        let secondSubscription = Task {
            for await text in source.updates() {
                secondSubscriptionValues.append(text)
            }
        }
        defer {
            secondSubscription.cancel()
        }

        try await MarkdownViewTestSupport.waitUntil {
            secondSubscriptionValues == ["Updated while hidden"]
        }

        source.text = "Updated after reappear"

        try await MarkdownViewTestSupport.waitUntil {
            secondSubscriptionValues == [
                "Updated while hidden",
                "Updated after reappear",
            ]
        }
    }

    @Test(
        "Finishes active and future subscriptions after streaming ends",
        .tags(.streaming)
    )
    func finishStreamingCompletesActiveAndFutureSubscriptions() async throws {
        let source = StreamingMarkdownSource("Initial")
        var activeSubscriptionValues: [String] = []
        var didFinishActiveSubscription = false

        let activeSubscription = Task {
            for await text in source.updates() {
                activeSubscriptionValues.append(text)
            }
            didFinishActiveSubscription = true
        }
        defer {
            activeSubscription.cancel()
        }

        try await MarkdownViewTestSupport.waitUntil {
            activeSubscriptionValues == ["Initial"]
        }

        source.finishStreaming()

        try await MarkdownViewTestSupport.waitUntil {
            didFinishActiveSubscription
        }

        var futureSubscriptionValues: [String] = []
        var didFinishFutureSubscription = false
        let futureSubscription = Task {
            for await text in source.updates() {
                futureSubscriptionValues.append(text)
            }
            didFinishFutureSubscription = true
        }
        defer {
            futureSubscription.cancel()
        }

        try await MarkdownViewTestSupport.waitUntil {
            didFinishFutureSubscription
        }

        #expect(futureSubscriptionValues.isEmpty)
    }
}
