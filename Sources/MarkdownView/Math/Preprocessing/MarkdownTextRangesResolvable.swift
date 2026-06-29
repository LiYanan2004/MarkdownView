//
//  MarkdownTextRangesResolvable.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/2.
//

import Markdown

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
        var index = string.startIndex
        var currentLine = 1
        while currentLine < line && index < string.endIndex {
            if string[index] == "\n" {
                currentLine += 1
            }
            index = string.index(after: index)
        }
        guard let utf8LineStart = index.samePosition(in: string.utf8) else {
            return string.endIndex
        }
        let byteOffset = column - 1
        let targetUTF8Index = string.utf8.index(utf8LineStart, offsetBy: byteOffset, limitedBy: string.utf8.endIndex) ?? string.utf8.endIndex
        return targetUTF8Index.samePosition(in: string) ?? string.endIndex
    }
}
