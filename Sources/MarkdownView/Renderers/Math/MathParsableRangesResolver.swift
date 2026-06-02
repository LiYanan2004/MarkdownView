//
//  MathParsableRangesResolver.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/2.
//

import Markdown

struct MathParsableRangesResolver: MarkupWalker {
    private var resolvableIncludedRanges: [SourceRange] = []
    private var resolvableExcludedRanges: [any MarkdownTextRangesResolvable] = []
    
    func resolve(in text: String) -> [Range<String.Index>] {
        let includedRanges = resolvableIncludedRanges
            .flatMap { $0.resolve(in: text) }
            .sorted { $0.lowerBound < $1.lowerBound }
        let excludedRanges = resolvableExcludedRanges.flatMap {
            $0.resolve(in: text)
        }

        return includedRanges.flatMap { includedRange in
            subtract(excludedRanges, from: includedRange)
        }
    }

    mutating func visitDocument(_ document: Document) {
        for child in document.children {
            if let range = child.range {
                resolvableIncludedRanges.append(range)
            }
            descendInto(child)
        }
    }

    mutating func defaultVisit(_ markup: any Markup) {
        descendInto(markup)
    }
    
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) {
        guard let range = codeBlock.range else { return }
        resolvableExcludedRanges.append(range)
    }

    mutating func visitInlineCode(_ inlineCode: InlineCode) {
        guard let range = inlineCode.range else { return }
        resolvableExcludedRanges.append(range)
    }

    mutating func visitLink(_ link: Link) {
        resolvableExcludedRanges.append(link)
        descendInto(link)
    }

    mutating func visitImage(_ image: Image) {
        guard let range = image.range else { return }
        resolvableExcludedRanges.append(range)
    }

    mutating func visitInlineHTML(_ inlineHTML: InlineHTML) {
        guard let range = inlineHTML.range else { return }
        resolvableExcludedRanges.append(range)
    }

    mutating func visitHTMLBlock(_ htmlBlock: HTMLBlock) {
        guard let range = htmlBlock.range else { return }
        resolvableExcludedRanges.append(range)
    }
}

fileprivate extension MathParsableRangesResolver {
    func subtract(
        _ excludedRanges: [Range<String.Index>],
        from includedRange: Range<String.Index>
    ) -> [Range<String.Index>] {
        var allowedRanges: [Range<String.Index>] = []
        let sortedExcludedRanges = excludedRanges
            .filter { $0.overlaps(includedRange) }
            .sorted { $0.lowerBound < $1.lowerBound }
        var currentStart = includedRange.lowerBound

        for excludedRange in sortedExcludedRanges {
            if currentStart < excludedRange.lowerBound {
                allowedRanges.append(
                    currentStart..<min(excludedRange.lowerBound, includedRange.upperBound)
                )
            }

            if currentStart < excludedRange.upperBound {
                currentStart = min(excludedRange.upperBound, includedRange.upperBound)
            }
        }

        if currentStart < includedRange.upperBound {
            allowedRanges.append(currentStart..<includedRange.upperBound)
        }

        return allowedRanges
    }
}
