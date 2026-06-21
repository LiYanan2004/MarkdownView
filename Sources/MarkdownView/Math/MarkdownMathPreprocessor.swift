//
//  MarkdownMathPreprocessor.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/16.
//

import Foundation
import Markdown

@_documentation(visibility: internal)
public struct MarkdownMathPreprocessor: Sendable, Hashable {
    public struct Result: Sendable, Hashable {
        public let markdown: String
        public let context: MarkdownMathContext

        public init(
            markdown: String,
            context: MarkdownMathContext
        ) {
            self.markdown = markdown
            self.context = context
        }
    }
    
    public func preprocess(_ markdown: String) -> String {
        preprocessingResult(for: markdown).markdown
    }
    
    public init() {
        
    }

    public func preprocessingResult(for markdown: String) -> MarkdownMathPreprocessor.Result {
        var mathRangesResolver = MathParsableRangesResolver()
        mathRangesResolver.visit(
            Document(
                parsing: markdown,
                options: ParseOptions().union(.parseBlockDirectives)
            )
        )

        return MathPlaceholderSubstituter.process(
            markdown,
            parsableRanges: mathRangesResolver.resolve(in: markdown)
        )
    }
}

extension MarkdownMathPreprocessor {
    static public func inlinePlaceholder(for identifier: UUID) -> String {
        "markdownview-inline-math-\(identifier.uuidString)"
    }
    
    static public func displayPlaceholder(for identifier: UUID) -> String {
        "@math(uuid: \"\(identifier.uuidString)\")"
    }
}

extension MarkdownMathPreprocessor.Result {
    var inlineMathStorage: [UUID: String] {
        context.inlineMathStorage
    }
    
    var displayMathStorage: [UUID: String] {
        context.displayMathStorage
    }
}
