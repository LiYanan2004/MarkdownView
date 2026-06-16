//
//  MDMathPreprocessor.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/16.
//

import Foundation
import Markdown

public struct MDMathPreprocessor: Sendable, Hashable {
    public func preprocess(_ markdown: String) -> String {
        preprocessingResult(for: markdown).markdown
    }
    
    public init() {
        
    }

    public func preprocessingResult(for markdown: String) -> MDMathPreprocessingResult {
        var mathRangesResolver = MathParsableRangesResolver()
        mathRangesResolver.visit(
            Document(
                parsing: markdown,
                options: ParseOptions().union(.parseBlockDirectives)
            )
        )

        return MathPlaceholderPreprocessor.process(
            markdown,
            parsableRanges: mathRangesResolver.resolve(in: markdown),
            includesInlineMath: includesInlineMath
        )
    }
    
    private var includesInlineMath: Bool {
        #if canImport(LaTeXSwiftUI)
        true
        #else
        false
        #endif
    }
}

extension MDMathPreprocessor {
    static public func inlinePlaceholder(for identifier: UUID) -> String {
        "markdownview-inline-math-\(identifier.uuidString)"
    }
    
    static public func displayPlaceholder(for identifier: UUID) -> String {
        "@math(uuid:\(identifier.uuidString))"
    }
}
