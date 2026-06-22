//
//  MathPlaceholderSubstituter.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/2.
//

import Foundation

enum MathPlaceholderSubstituter {
    static func process(
        _ markdown: String,
        parsableRanges: [Range<String.Index>]
    ) -> MarkdownMathPreprocessor.Result {
        var replacements: [Replacement] = []
        var inlineMathStorage: [UUID: String] = [:]
        var displayMathStorage: [UUID: String] = [:]

        for parsableRange in parsableRanges {
            let segment = markdown[parsableRange]
            let segmentParser = MathParser(text: segment)

            for math in segmentParser.mathRepresentations {
                let matchedText = String(markdown[math.range])
                let lowerBoundOffset = markdown.distance(
                    from: markdown.startIndex,
                    to: math.range.lowerBound
                )
                let upperBoundOffset = markdown.distance(
                    from: markdown.startIndex,
                    to: math.range.upperBound
                )
                let sourceRange = lowerBoundOffset..<upperBoundOffset
                let identifier = MarkdownMathPreprocessor.stableIdentifier(
                    matchedText: matchedText,
                    sourceRange: sourceRange
                )
                let placeholder: String

                if math.kind.inline {
                    inlineMathStorage[identifier] = matchedText
                    placeholder = MarkdownMathPreprocessor.inlinePlaceholder(for: identifier)
                } else {
                    displayMathStorage[identifier] = matchedText
                    placeholder = MarkdownMathPreprocessor.displayPlaceholder(for: identifier)
                }
                replacements.append(
                    Replacement(
                        range: sourceRange,
                        placeholder: placeholder
                    )
                )
            }
        }

        let sortedReplacements = replacements.sorted { $0.range.lowerBound < $1.range.lowerBound }
        var processedReplacements: [MarkdownMathPreprocessor.Replacement] = []
        processedReplacements.reserveCapacity(sortedReplacements.count)

        var processedMarkdown = ""
        processedMarkdown.reserveCapacity(markdown.count)

        var sourceCursor = markdown.startIndex
        var processedOffset = 0

        for replacement in sortedReplacements {
            let replacementLowerBound = markdown.index(
                markdown.startIndex,
                offsetBy: replacement.range.lowerBound
            )
            let replacementUpperBound = markdown.index(
                markdown.startIndex,
                offsetBy: replacement.range.upperBound
            )
            let unchangedSegment = markdown[sourceCursor..<replacementLowerBound]
            processedMarkdown.append(contentsOf: unchangedSegment)
            processedOffset += markdown.distance(
                from: sourceCursor,
                to: replacementLowerBound
            )

            let placeholderRange = processedOffset..<(processedOffset + replacement.placeholder.count)
            processedMarkdown.append(replacement.placeholder)
            processedReplacements.append(
                MarkdownMathPreprocessor.Replacement(
                    sourceRange: replacement.range,
                    processedRange: placeholderRange
                )
            )
            processedOffset = placeholderRange.upperBound
            sourceCursor = replacementUpperBound
        }

        processedMarkdown.append(contentsOf: markdown[sourceCursor...])

        return MarkdownMathPreprocessor.Result(
            markdown: processedMarkdown,
            context: MarkdownMathContext(
                inlineMathStorage: inlineMathStorage,
                displayMathStorage: displayMathStorage
            ),
            replacements: processedReplacements
        )
    }
}

fileprivate extension MathPlaceholderSubstituter {
    struct Replacement {
        var range: Range<Int>
        var placeholder: String
    }
}
