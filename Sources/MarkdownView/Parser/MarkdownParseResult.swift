//
//  MarkdownParseResult.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/28.
//

import Foundation
import Markdown

public struct MarkdownParseResult: Sendable {
    public var document: Markdown.Document
    public var mode: ParsingStrategy
    public let sourceSnapshot: Snapshot
    public let processedSnapshot: Snapshot
    public var parseOptions: MarkdownDocumentParsingOptions
    public var mathContext: MarkdownMathContext?
    
    func retained() -> MarkdownParseResult {
        var copy = self
        copy.mode = .retained
        return copy
    }
}

extension MarkdownParseResult {
    public enum ParsingStrategy: Sendable, Hashable {
        /// Reuses the previous parse result without additional parsing.
        case retained

        /// Performs incremental parsing.
        case incremental(stablePrefixRootBlockCount: Int)

        /// Performs a full parse.
        case full
    }
    
    public struct Snapshot: Sendable, Hashable {
        public let text: String
        public let blockRanges: [Range<String.Index>]
    }
}

extension MarkdownParseResult: Equatable {
    public static func == (lhs: MarkdownParseResult, rhs: MarkdownParseResult) -> Bool {
        lhs.document.isIdentical(to: rhs.document) &&
        lhs.mode == rhs.mode &&
        lhs.sourceSnapshot == rhs.sourceSnapshot &&
        lhs.processedSnapshot == rhs.processedSnapshot &&
        lhs.parseOptions == rhs.parseOptions &&
        lhs.mathContext == rhs.mathContext
    }
}
