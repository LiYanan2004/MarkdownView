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
    ) -> MDMathPreprocessor.Result {
        var replacements: [Replacement] = []
        var inlineMathStorage: [UUID: String] = [:]
        var displayMathStorage: [UUID: String] = [:]

        for parsableRange in parsableRanges {
            let segment = markdown[parsableRange]
            let segmentParser = MathParser(text: segment)

            for math in segmentParser.mathRepresentations {
                let identifier = UUID()
                let matchedText = String(markdown[math.range])
                let placeholder: String

                if math.kind.inline {
                    inlineMathStorage[identifier] = matchedText
                    placeholder = MDMathPreprocessor.inlinePlaceholder(for: identifier)
                } else {
                    displayMathStorage[identifier] = matchedText
                    placeholder = MDMathPreprocessor.displayPlaceholder(for: identifier)
                }

                let lowerBoundOffset = markdown.distance(
                    from: markdown.startIndex,
                    to: math.range.lowerBound
                )
                let upperBoundOffset = markdown.distance(
                    from: markdown.startIndex,
                    to: math.range.upperBound
                )
                replacements.append(
                    Replacement(
                        range: lowerBoundOffset..<upperBoundOffset,
                        placeholder: placeholder
                    )
                )
            }
        }

        var processedMarkdown = markdown
        for replacement in replacements.sorted(by: { $0.range.lowerBound > $1.range.lowerBound }) {
            let lowerBound = processedMarkdown.index(
                processedMarkdown.startIndex,
                offsetBy: replacement.range.lowerBound
            )
            let upperBound = processedMarkdown.index(
                processedMarkdown.startIndex,
                offsetBy: replacement.range.upperBound
            )
            processedMarkdown.replaceSubrange(
                lowerBound..<upperBound,
                with: replacement.placeholder
            )
        }

        return MDMathPreprocessor.Result(
            markdown: processedMarkdown,
            context: MDMathContext(
                inlineMathStorage: inlineMathStorage,
                displayMathStorage: displayMathStorage
            )
        )
    }
}

fileprivate extension MathPlaceholderSubstituter {
    struct Replacement {
        var range: Range<Int>
        var placeholder: String
    }
}
