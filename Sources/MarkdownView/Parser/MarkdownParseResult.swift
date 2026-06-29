//
//  MarkdownParseResult.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/28.
//

import Foundation
import Markdown

/// A parsed markdown document and the rendering metadata produced during parsing.
public struct MarkdownParseResult: Sendable {
    /// The parsed markdown document.
    public var document: Markdown.Document

    /// The parsing strategy used to produce the document.
    public var parsingStrategy: ParsingStrategy

    /// A snapshot of the original source text.
    public let sourceSnapshot: Snapshot

    /// A snapshot of the text after preprocessing.
    public let processedSnapshot: Snapshot

    /// The options used to parse the document.
    public var parseOptions: MarkdownDocumentParsingOptions

    /// The math context produced during parsing.
    public var mathContext: MarkdownMathContext?

    /// The absolute processed-text start location for each root block.
    package let processedBlockStartLocations: [SourceLocation]

    package func retained() -> MarkdownParseResult {
        var copy = self
        copy.parsingStrategy = .retained
        return copy
    }
}

extension MarkdownParseResult {
    /// A strategy that describes how a parse result was produced.
    public enum ParsingStrategy: Sendable, Hashable {
        /// Reuses the previous parse result without additional parsing.
        case retained

        /// Performs incremental parsing.
        ///
        /// The associated value is the number of stable root blocks reused from the previous parse result.
        case incremental(stablePrefixRootBlockCount: Int)

        /// Performs a full parse.
        case full
    }
    
    /// A source snapshot used to compare document state across parses.
    public struct Snapshot: Sendable, Hashable {
        /// The snapshot text.
        public let text: String

        /// The source ranges for the root-level markdown blocks in `text`.
        public let blockRanges: [Range<String.Index>]
    }
}

extension MarkdownParseResult: Equatable {
    /// Returns whether two parse results describe the same parsed document and parsing metadata.
    public static func == (lhs: MarkdownParseResult, rhs: MarkdownParseResult) -> Bool {
        lhs.document.isIdentical(to: rhs.document) &&
        lhs.parsingStrategy == rhs.parsingStrategy &&
        lhs.sourceSnapshot == rhs.sourceSnapshot &&
        lhs.processedSnapshot == rhs.processedSnapshot &&
        lhs.parseOptions == rhs.parseOptions &&
        lhs.mathContext == rhs.mathContext &&
        lhs.processedBlockStartLocations == rhs.processedBlockStartLocations
    }
}
