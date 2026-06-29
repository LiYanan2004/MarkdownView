//
//  MarkdownMathContext.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/16.
//

import Foundation

@_documentation(visibility: internal)
public struct MarkdownMathContext: Sendable, Hashable {
    public var inlineMathStorage: [UUID: String]
    public var displayMathStorage: [UUID: String]

    init(
        inlineMathStorage: [UUID: String] = [:],
        displayMathStorage: [UUID: String] = [:]
    ) {
        self.inlineMathStorage = inlineMathStorage
        self.displayMathStorage = displayMathStorage
    }
}
