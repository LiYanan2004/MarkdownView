//
//  MarkdownTextRangesResolvable.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/2.
//

import Markdown
import Foundation

protocol MarkdownTextRangesResolvable {
    func resolve(in text: String) -> [Range<String.Index>]
}

extension SourceRange: MarkdownTextRangesResolvable {
    func resolve(in text: String) -> [Range<String.Index>] {
        [(lowerBound.index(in: text)..<upperBound.index(in: text))]
    }
}

extension Link: MarkdownTextRangesResolvable {
    func resolve(in text: String) -> [Range<String.Index>] {
        guard let range else { return [] }

        let sourceRange = range.lowerBound.index(in: text)..<range.upperBound.index(in: text)
        var excludedRanges: [Range<String.Index>] = []
        let metadataStart = text.range(
            of: "](",
            range: sourceRange
        )?.upperBound ?? sourceRange.lowerBound
        var searchRange = metadataStart..<sourceRange.upperBound

        if let destination,
           let destinationRange = text.range(of: destination, range: searchRange) {
            excludedRanges.append(destinationRange)
            searchRange = destinationRange.upperBound..<sourceRange.upperBound
        }

        if let title,
           let titleRange = text.range(of: title, range: searchRange) {
            excludedRanges.append(titleRange)
        }

        return excludedRanges
    }
}

// MARK: - Auxiliary

fileprivate extension SourceLocation {
    func index(in string: String) -> String.Index {
        var idx = string.startIndex
        var currentLine = 1
        while currentLine < self.line && idx < string.endIndex {
            if string[idx] == "\n" {
                currentLine += 1
            }
            idx = string.index(after: idx)
        }
        guard let utf8LineStart = idx.samePosition(in: string.utf8) else {
            return string.endIndex
        }
        let byteOffset = self.column - 1
        let targetUtf8Index = string.utf8.index(utf8LineStart, offsetBy: byteOffset, limitedBy: string.utf8.endIndex) ?? string.utf8.endIndex
        return targetUtf8Index.samePosition(in: string) ?? string.endIndex
    }
}
