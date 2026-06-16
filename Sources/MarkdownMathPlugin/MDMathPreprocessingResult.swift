//
//  MDMathPreprocessingResult.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/16.
//

import Foundation

public struct MDMathPreprocessingResult: Sendable, Hashable {
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

public extension MDMathPreprocessingResult {
    var inlineMathStorage: [UUID: String] {
        context.inlineMathStorage
    }

    var displayMathStorage: [UUID: String] {
        context.displayMathStorage
    }
}
