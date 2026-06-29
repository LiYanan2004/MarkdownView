//
//  StreamingMarkdownSource.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/28.
//

import Foundation
import OSLog

/// An efficient markdown source for ``StreamingMarkdownReader``.
///
/// Updating ``text`` does not trigger any SwiftUI view updates by itself. `StreamingMarkdownSource` stores the latest value and delivers it through its own update stream.
///
/// `StreamingMarkdownSource` also owns its update cycle. `StreamingMarkdownReader` consumes values from this source independently from SwiftUI view updates. This matters when markdown arrives faster than SwiftUI can reliably observe through view-driven mechanisms such as `onChange` or `task`.
///
/// For example, if content updates once every 1 millisecond, SwiftUI view updates can coalesce those changes and some callback deliveries can be skipped, resulting in incomplete markdown document rendering.
///
/// `StreamingMarkdownSource` keeps those source updates in its own stream so the ``StreamingMarkdownReader`` can continue processing the latest values without depending on SwiftUI's view update timing.
///
/// The following example appends chunks from an async sequence into a source.
///
/// ```swift
/// import SwiftUI
/// import MarkdownView
///
/// struct StreamingResponseView: View {
///     @State private var markdownSource = StreamingMarkdownSource()
///
///     let chunks: AsyncStream<String>
///
///     var body: some View {
///         StreamingMarkdownReader(markdownSource) { parseResult in
///             MarkdownView(parseResult)
///         }
///         .task {
///             for await chunk in chunks {
///                 markdownSource.text += chunk
///             }
///
///             markdownSource.finishStreaming()
///         }
///     }
/// }
/// ```
///
/// Call ``finishStreaming()`` when the response is complete. A finished source keeps storing new ``text`` values, but it stops emitting updates; create a new source for a new streaming response after finishing the current one.
public final class StreamingMarkdownSource: @unchecked Sendable {
    @OSUnfairLockProtected private var storage: StreamingMarkdownSourceStorage

    /// The latest markdown text for the streaming reader.
    ///
    /// Assign a new value whenever new markdown content is available.
    public var text: String {
        get { storage.text }
        set {
            let continuations = $storage.withLockUnchecked { storage in
                storage.text = newValue

                guard storage.isFinished == false else {
                    return [UUID: AsyncStream<String>.Continuation]()
                }

                return storage.continuations
            }

            let terminatedSubscriptionIDs = continuations.compactMap { subscriptionID, continuation in
                if case .terminated = continuation.yield(newValue) {
                    return subscriptionID
                }
                return nil
            }

            if terminatedSubscriptionIDs.isEmpty == false {
                Logger.streaming.warning("StreamingMarkdownSource received a text update while \(terminatedSubscriptionIDs.count) registered stream subscriptions were already terminated. The latest text was stored, but those subscriptions did not receive the update.")
                removeContinuations(for: terminatedSubscriptionIDs)
            }
        }
    }

    /// Creates a streaming markdown source with an initial text value.
    ///
    /// - Parameter text: The initial markdown text.
    public init(_ text: String = "") {
        self.storage = StreamingMarkdownSourceStorage(text: text)
    }

    /// Finishes the streaming update cycle.
    ///
    /// Call this method when no more markdown updates will arrive.
    ///
    /// This finishes the source's internal update stream so ``StreamingMarkdownReader`` stops receiving new values from this source.
    /// After the stream finishes, ``StreamingMarkdownReader`` may still perform one final full parse from the last emitted text value so the final rendered document reflects fully resolved markdown structure.
    ///
    /// Once this method is called, this source instance will store future ``text`` changes but will not emit them.
    public func finishStreaming() {
        let continuations = $storage.withLockUnchecked { storage in
            guard storage.isFinished == false else {
                return [AsyncStream<String>.Continuation]()
            }

            storage.isFinished = true
            let continuations = Array(storage.continuations.values)
            storage.continuations.removeAll()
            return continuations
        }

        for continuation in continuations {
            continuation.finish()
        }
    }
}

private struct StreamingMarkdownSourceStorage: Sendable {
    var text: String
    var isFinished = false
    var continuations: [UUID: AsyncStream<String>.Continuation] = [:]
}

extension StreamingMarkdownSource {
    func updates() -> AsyncStream<String> {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let subscriptionID = UUID()

            continuation.onTermination = { @Sendable [weak self] _ in
                self?.removeContinuation(for: subscriptionID)
            }

            let initialText = $storage.withLockUnchecked { storage -> String? in
                guard storage.isFinished == false else {
                    return nil
                }

                storage.continuations[subscriptionID] = continuation
                return storage.text
            }

            guard let initialText else {
                continuation.finish()
                return
            }

            if case .terminated = continuation.yield(initialText) {
                removeContinuation(for: subscriptionID)
            }
        }
    }

    private func removeContinuation(for subscriptionID: UUID) {
        $storage.withLock { storage in
            storage.continuations[subscriptionID] = nil
        }
    }

    private func removeContinuations(for subscriptionIDs: [UUID]) {
        $storage.withLock { storage in
            for subscriptionID in subscriptionIDs {
                storage.continuations[subscriptionID] = nil
            }
        }
    }
}
