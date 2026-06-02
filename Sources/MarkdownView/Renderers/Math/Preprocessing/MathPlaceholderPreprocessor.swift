//
//  MathPlaceholderPreprocessor.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/2.
//

import Foundation

package enum MathPlaceholderPreprocessor {
    package static func process(
        _ markdown: String,
        parsableRanges: [Range<String.Index>],
        includeInlineMath: Bool = true
    ) -> Result {
        var replacements: [Replacement] = []
        var inlineMathStorage: [UUID: String] = [:]
        var displayMathStorage: [UUID: String] = [:]

        for parsableRange in parsableRanges {
            let segment = markdown[parsableRange]
            let segmentParser = MathParser(text: segment)

            for math in segmentParser.mathRepresentations {
                if math.kind.inline && !includeInlineMath {
                    continue
                }

                let identifier = UUID()
                let latexText = String(markdown[math.range])
                let placeholder: String

                if math.kind.inline {
                    inlineMathStorage[identifier] = latexText
                    placeholder = Self.inlinePlaceholder(for: identifier)
                } else {
                    displayMathStorage[identifier] = latexText
                    placeholder = Self.displayPlaceholder(for: identifier)
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

        return Result(
            markdown: processedMarkdown,
            inlineMathStorage: inlineMathStorage,
            displayMathStorage: displayMathStorage
        )
    }

    static func inlinePlaceholder(for identifier: UUID) -> String {
        "markdownview-inline-math-\(identifier.uuidString)"
    }

    static func displayPlaceholder(for identifier: UUID) -> String {
        "@math(uuid:\(identifier.uuidString))"
    }
}

extension MathPlaceholderPreprocessor {
    public struct Result {
        public let markdown: String
        public let inlineMathStorage: [UUID : String]
        public let displayMathStorage: [UUID : String]
    }
}

fileprivate extension MathPlaceholderPreprocessor {
    struct Replacement {
        var range: Range<Int>
        var placeholder: String
    }
}
