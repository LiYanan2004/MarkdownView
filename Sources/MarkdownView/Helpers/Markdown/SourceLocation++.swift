//
//  SourceLocation++.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/1/18.
//

import Markdown

extension SourceLocation {
    @available(*, deprecated, message: "Use `SourceLocation.offset(in:) -> String.Index` instead")
    func offset(in text: String) -> Int {
        let colIndex = column - 1
        let previousLinesTotalChar = text
            .split(separator: "\n", maxSplits: line - 1, omittingEmptySubsequences: false)
            .dropLast()
            .map { String($0) }
            .joined(separator: "\n")
            .count
        return previousLinesTotalChar + colIndex + 1
    }
    
    func offset(in text: String) -> String.Index {
        let colIndex = column - 1
        let previousLinesTotalChar = text
            .split(separator: "\n", maxSplits: line - 1, omittingEmptySubsequences: false)
            .dropLast()
            .joined(separator: "\n")
            .count
        return text.index(text.startIndex, offsetBy: previousLinesTotalChar + colIndex + 1)
    }
}
