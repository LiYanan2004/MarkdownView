//
//  String++.swift
//  MarkdownView
//

import Foundation

extension String {
    func stringIndex(
        forLine targetLine: Int,
        column targetColumn: Int
    ) -> String.Index? {
        guard targetLine > 0, targetColumn > 0 else { return nil }

        var currentLine = 1
        var lineStartIndex = self.startIndex

        while currentLine < targetLine {
            guard let newlineIndex = self[lineStartIndex...].firstIndex(of: "\n") else {
                return nil
            }
            lineStartIndex = self.index(after: newlineIndex)
            currentLine += 1
        }

        let targetOffset = targetColumn - 1
        let lineEndIndex: String.Index
        if let newlineIndex = self[lineStartIndex...].firstIndex(of: "\n") {
            lineEndIndex = newlineIndex
        } else {
            lineEndIndex = self.endIndex
        }

        let maximumOffset = self.distance(from: lineStartIndex, to: lineEndIndex)
        if targetOffset > maximumOffset {
            return lineEndIndex
        }

        return self.index(lineStartIndex, offsetBy: targetOffset)
    }
}

