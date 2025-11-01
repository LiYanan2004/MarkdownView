//
//  BackgroundMarkdownParser.swift
//  MarkdownView
//
//  Created for streaming markdown rendering optimization
//

@preconcurrency import Markdown
import Foundation

/// Manages background parsing of markdown text to keep the main thread responsive
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
actor BackgroundMarkdownParser {
    private var currentParseTask: Task<Document, Never>?

    /// Parse markdown text on a background thread with optional throttling
    /// Cancels any in-flight parse operations
    func parse(_ text: String, throttle: Duration? = nil) async -> Document {
        // Cancel any existing parse task
        currentParseTask?.cancel()

        // Create new parse task
        let task = Task.detached(priority: .userInitiated) {
            // Optional throttling to batch rapid updates
            if let throttle = throttle {
                try? await Task.sleep(for: throttle)
            }

            // Check if cancelled before expensive parsing
            try? Task.checkCancellation()

            // Parse the document
            // Note: MarkdownContent handles the actual parsing
            let content = MarkdownContent(raw: .plainText(text))
            return content.document
        }

        currentParseTask = task

        return await task.value
    }

    /// Cancel any ongoing parse operation
    func cancelParsing() {
        currentParseTask?.cancel()
        currentParseTask = nil
    }
}

/// Statistics tracker for parsing performance
@MainActor
class ParsingStatistics: ObservableObject {
    @Published var totalParses: Int = 0
    @Published var averageParseTime: TimeInterval = 0
    @Published var lastParseTime: TimeInterval = 0

    private var parseTimes: [TimeInterval] = []

    func recordParse(duration: TimeInterval) {
        totalParses += 1
        lastParseTime = duration
        parseTimes.append(duration)

        // Keep only last 100 measurements
        if parseTimes.count > 100 {
            parseTimes.removeFirst()
        }

        averageParseTime = parseTimes.reduce(0, +) / Double(parseTimes.count)
    }

    func reset() {
        totalParses = 0
        averageParseTime = 0
        lastParseTime = 0
        parseTimes.removeAll()
    }

    var statistics: String {
        """
        Parsing Statistics:
        - Total Parses: \(totalParses)
        - Last Parse: \(String(format: "%.1fms", lastParseTime * 1000))
        - Average Parse: \(String(format: "%.1fms", averageParseTime * 1000))
        """
    }
}
