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
    @Test("New subscription receives latest text after previous subscription is cancelled")
    func newSubscriptionReceivesLatestTextAfterPreviousSubscriptionIsCancelled() async throws {
        let source = StreamingMarkdownSource("Initial")
        var firstSubscriptionValues: [String] = []

        let firstSubscription = Task {
            for await text in source.updates() {
                firstSubscriptionValues.append(text)
            }
        }

        try await waitUntil {
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

        try await waitUntil {
            secondSubscriptionValues == ["Updated while hidden"]
        }

        source.text = "Updated after reappear"

        try await waitUntil {
            secondSubscriptionValues == [
                "Updated while hidden",
                "Updated after reappear",
            ]
        }
    }

    @Test("Finish streaming completes active and future subscriptions")
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

        try await waitUntil {
            activeSubscriptionValues == ["Initial"]
        }

        source.finishStreaming()

        try await waitUntil {
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

        try await waitUntil {
            didFinishFutureSubscription
        }

        #expect(futureSubscriptionValues.isEmpty)
    }
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

    #expect(condition(), "Timed out waiting for condition.")
}
