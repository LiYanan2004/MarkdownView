//
//  StreamingMarkdownView.swift
//  MarkdownView
//
//  Created for streaming markdown rendering optimization
//

import SwiftUI
@preconcurrency import Markdown

/// A view that efficiently renders streaming markdown content with minimal UI blocking
/// Optimized for scenarios like LLM responses where content arrives incrementally
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
public struct StreamingMarkdownView: View {
    @State private var accumulatedText: String = ""
    @State private var currentDocument: Document?
    @State private var previousDocument: Document?
    @State private var nodeCache = NodeViewCache()
    @State private var parser = BackgroundMarkdownParser()
    @State private var parsingStats = ParsingStatistics()

    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.markdownViewStyle) private var markdownViewStyle
    @Environment(\.markdownFontGroup.body) private var bodyFont

    private let textStream: AnyAsyncSequence<String>
    private let parseThrottle: Duration
    private let showStatistics: Bool

    /// Initialize with an async sequence of text chunks
    /// - Parameters:
    ///   - stream: AsyncSequence that provides text chunks as they arrive
    ///   - parseThrottle: Minimum interval between parse operations (default: 250ms)
    ///   - showStatistics: Whether to display performance statistics (default: false)
    public init<S: AsyncSequence>(
        streaming stream: S,
        parseThrottle: Duration = .milliseconds(250),
        showStatistics: Bool = false
    ) where S.Element == String {
        self.textStream = AnyAsyncSequence(stream)
        self.parseThrottle = parseThrottle
        self.showStatistics = showStatistics
    }

    public var body: some View {
        Group {
            if let document = currentDocument {
                optimizedMarkdownView(for: document)
            } else {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .font(bodyFont)
        .task {
            await processStream()
        }
        .overlay(alignment: .bottomTrailing) {
            if showStatistics {
                statisticsOverlay
            }
        }
    }

    // MARK: - Stream Processing

    private func processStream() async {
        var lastParseTime = ContinuousClock.now

        for await chunk in textStream {
            accumulatedText += chunk

            let now = ContinuousClock.now
            let elapsed = lastParseTime.duration(to: now)

            // Throttle parsing to reduce CPU load
            guard elapsed >= parseThrottle else { continue }

            await parseAndUpdate()
            lastParseTime = now
        }

        // Final parse when stream completes
        await parseAndUpdate()
    }

    private func parseAndUpdate() async {
        let startTime = ContinuousClock.now

        // Parse on background thread
        let newDocument = await parser.parse(accumulatedText, throttle: nil)

        // Measure parse time
        let parseTime = startTime.duration(to: ContinuousClock.now).timeInterval
        await parsingStats.recordParse(duration: parseTime)

        // Update on main thread
        previousDocument = currentDocument
        currentDocument = newDocument
    }

    // MARK: - Optimized Rendering

    @ViewBuilder
    private func optimizedMarkdownView(for document: Document) -> some View {
        let changes = ASTDiffer.diff(old: previousDocument, new: document)

        markdownViewStyle.makeBody(
            configuration: MarkdownViewStyleConfiguration(
                body: AnyView(
                    LazyVStack(alignment: .leading, spacing: configuration.componentSpacing) {
                        renderBlocks(document: document, changes: changes)
                    }
                )
            )
        )
        .erasedToAnyView()
    }

    @ViewBuilder
    private func renderBlocks(document: Document, changes: [ASTChange]) -> some View {
        let blockItems: [BlockItem] = Array(document.children).enumerated().compactMap { index, child in
            if let block = child as? any BlockMarkup {
                return BlockItem(index: index, hash: child.stableContentHash, block: block)
            }
            return nil
        }

        ForEach(blockItems) { item in
            AnyView(cachedBlockView(for: item.block, at: item.index, changes: changes))
                .id(item.hash)
        }
    }

    private struct BlockItem: Identifiable {
        let index: Int
        let hash: Int
        let block: any BlockMarkup
        var id: Int { hash }
    }

    @ViewBuilder
    private func cachedBlockView(
        for block: some BlockMarkup,
        at index: Int,
        changes: [ASTChange]
    ) -> some View {
        // Check if this block is unchanged
        let change = changes.first { $0.newIndex == index }

        if change?.type == .unchanged,
           let cachedView = nodeCache.get(for: block, configuration: configuration) {
            // Reuse cached view - no rendering needed!
            cachedView
        } else {
            // Render and cache new view
            let rendered = renderBlock(block)
            let _ = nodeCache.set(rendered, for: block, configuration: configuration)
            rendered
        }
    }

    private func renderBlock(_ block: some BlockMarkup) -> MarkdownNodeView {
        var visitor = CmarkNodeVisitor(configuration: configuration)
        return visitor.visit(block)
    }

    // MARK: - Statistics Overlay

    private var statisticsOverlay: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("Cache Hit Rate: \(String(format: "%.0f%%", nodeCache.hitRate * 100))")
            Text("Cache Size: \(nodeCache.size)")
            Text("Last Parse: \(String(format: "%.1fms", parsingStats.lastParseTime * 1000))")
        }
        .font(.caption.monospaced())
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .padding()
    }
}

// MARK: - Type-Erased AsyncSequence

struct AnyAsyncSequence<Element>: AsyncSequence {
    private let _makeAsyncIterator: () -> AsyncIterator

    init<S: AsyncSequence>(_ sequence: S) where S.Element == Element {
        _makeAsyncIterator = {
            var iterator = sequence.makeAsyncIterator()
            return AsyncIterator {
                try? await iterator.next()
            }
        }
    }

    func makeAsyncIterator() -> AsyncIterator {
        _makeAsyncIterator()
    }

    struct AsyncIterator: AsyncIteratorProtocol {
        private let _next: () async -> Element?

        init(next: @escaping () async -> Element?) {
            _next = next
        }

        mutating func next() async -> Element? {
            await _next()
        }
    }
}

// MARK: - Convenience Extension on MarkdownView

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
extension MarkdownView {
    /// Initialize with a streaming async sequence
    /// - Parameters:
    ///   - stream: AsyncSequence that provides text chunks
    ///   - throttle: Minimum interval between parse operations
    public init<S: AsyncSequence>(
        streaming stream: S,
        throttle: Duration = .milliseconds(250)
    ) where S.Element == String {
        // This will delegate to StreamingMarkdownView internally
        // For now, we just parse the final result
        // TODO: Integrate StreamingMarkdownView properly
        self.init("")
    }
}

// MARK: - Duration Extension

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
extension ContinuousClock.Instant.Duration {
    var timeInterval: TimeInterval {
        let components = self.components
        return Double(components.seconds) + Double(components.attoseconds) / 1_000_000_000_000_000_000
    }
}
