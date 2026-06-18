//
//  MDMathPreprocessor.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/16.
//

import Foundation
import Markdown

public struct MDMathPreprocessor: Sendable, Hashable {
    public struct Result: Sendable, Hashable {
        public let markdown: String
        public let context: MDMathContext

        public init(
            markdown: String,
            context: MDMathContext
        ) {
            self.markdown = markdown
            self.context = context
        }
    }
    
    public func preprocess(
        _ markdown: String,
        includesInlineMath: Bool = true
    ) -> String {
        preprocessingResult(
            for: markdown,
            includesInlineMath: includesInlineMath
        ).markdown
    }
    
    public init() {
        
    }

    public func preprocessingResult(
        for markdown: String,
        includesInlineMath: Bool = true
    ) -> MDMathPreprocessor.Result {
        var mathRangesResolver = MathParsableRangesResolver()
        mathRangesResolver.visit(
            Document(
                parsing: markdown,
                options: ParseOptions().union(.parseBlockDirectives)
            )
        )

        return MathPlaceholderSubstituter.process(
            markdown,
            parsableRanges: mathRangesResolver.resolve(in: markdown),
            includesInlineMath: includesInlineMath
        )
    }
}

extension MDMathPreprocessor {
    static public func inlinePlaceholder(for identifier: UUID) -> String {
        "markdownview-inline-math-\(identifier.uuidString)"
    }
    
    static public func displayPlaceholder(for identifier: UUID) -> String {
        "@math(uuid: \"\(identifier.uuidString)\")"
    }
}

extension MDMathPreprocessor.Result {
    package var inlineMathStorage: [UUID: String] {
        context.inlineMathStorage
    }
    
    package var displayMathStorage: [UUID: String] {
        context.displayMathStorage
    }
}
