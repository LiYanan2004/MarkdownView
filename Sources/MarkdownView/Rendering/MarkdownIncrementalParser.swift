//
//  MarkdownIncrementalParser.swift
//  MarkdownView
//

import Foundation
import Markdown

struct MarkdownIncrementalParser {
    struct PreviousState {
        let sourceText: String
        let document: Markdown.Document
        let configuration: MarkdownRendererConfiguration
        let parsesBlockDirectives: Bool
        let rootBlockRanges: [RootBlockRange]?
    }

    struct ParseResult {
        let renderingInput: MarkdownRenderingInput
        let rootBlockRanges: [RootBlockRange]?
        let usedIncrementalParsing: Bool
        let stablePrefixRootBlockCount: Int?
    }

    struct RootBlockRange {
        let startIndex: String.Index
        let endIndex: String.Index
    }

    func parse(
        sourceText: String,
        configuration: MarkdownRendererConfiguration,
        parsesBlockDirectives: Bool,
        previousState: PreviousState?
    ) -> ParseResult {
        guard configuration.math.shouldRender == false else {
            return fullParse(
                sourceText: sourceText,
                configuration: configuration,
                parsesBlockDirectives: parsesBlockDirectives
            )
        }

        guard let previousState,
              previousState.configuration == configuration,
              previousState.parsesBlockDirectives == parsesBlockDirectives,
              let incrementalResult = parseIncremental(
                  previousState: previousState,
                  newSourceText: sourceText,
                  configuration: configuration,
                  parsesBlockDirectives: parsesBlockDirectives
              )
        else {
            return fullParse(
                sourceText: sourceText,
                configuration: configuration,
                parsesBlockDirectives: parsesBlockDirectives
            )
        }

        return incrementalResult
    }
}

private extension MarkdownIncrementalParser {
    func fullParse(
        sourceText: String,
        configuration: MarkdownRendererConfiguration,
        parsesBlockDirectives: Bool
    ) -> ParseResult {
        let renderingInput = MarkdownRenderingInput(
            source: .rawText(sourceText),
            configuration: configuration,
            parsesBlockDirectives: parsesBlockDirectives
        )
        return ParseResult(
            renderingInput: renderingInput,
            rootBlockRanges: parseRootBlockRanges(
                in: sourceText,
                document: renderingInput.document
            ),
            usedIncrementalParsing: false,
            stablePrefixRootBlockCount: nil
        )
    }

    func parseIncremental(
        previousState: PreviousState,
        newSourceText: String,
        configuration: MarkdownRendererConfiguration,
        parsesBlockDirectives: Bool
    ) -> ParseResult? {
        let previousSourceText = previousState.sourceText
        guard previousSourceText.isEmpty == false else { return nil }
        guard newSourceText.count > previousSourceText.count else { return nil }

        let previousRootBlocks = Array(previousState.document.children)
        guard previousRootBlocks.isEmpty == false else { return nil }

        let previousRanges = previousState.rootBlockRanges
            ?? parseRootBlockRanges(in: previousSourceText, document: previousState.document)
        guard previousRanges.isEmpty == false else { return nil }

        let reparsedRootBlockIndex = reparsedRootBlockIndex(
            in: previousSourceText,
            rootBlockRanges: previousRanges
        )
        let stableRootBlockCount = reparsedRootBlockIndex
        let reparsedStartIndex = previousRanges[reparsedRootBlockIndex].startIndex

        let stablePrefixText = previousSourceText[..<reparsedStartIndex]
        guard newSourceText.starts(with: stablePrefixText) else { return nil }

        let tailSourceText = String(newSourceText[reparsedStartIndex...])
        let tailRenderingInput = MarkdownRenderingInput(
            source: .rawText(tailSourceText),
            configuration: configuration,
            parsesBlockDirectives: parsesBlockDirectives
        )

        let mergedChildren = previousRootBlocks
            .prefix(stableRootBlockCount)
            .map(\.detachedFromParent)
            + Array(tailRenderingInput.document.children).map(\.detachedFromParent)
        guard let mergedDocument = previousState.document
            .withUncheckedChildren(mergedChildren) as? Markdown.Document
        else {
            return nil
        }

        let tailRanges = parseRootBlockRanges(
            in: tailSourceText,
            document: tailRenderingInput.document
        )
        let mergedRanges = Array(previousRanges.prefix(stableRootBlockCount))
            + shiftRootBlockRanges(
                tailRanges,
                from: tailSourceText,
                into: newSourceText,
                at: reparsedStartIndex
            )

        return ParseResult(
            renderingInput: MarkdownRenderingInput(
                document: mergedDocument,
                configuration: tailRenderingInput.configuration
            ),
            rootBlockRanges: mergedRanges,
            usedIncrementalParsing: true,
            stablePrefixRootBlockCount: stableRootBlockCount
        )
    }

    func parseRootBlockRanges(
        in markdown: String,
        document: Markdown.Document
    ) -> [RootBlockRange] {
        var rootBlockRanges: [RootBlockRange] = []
        rootBlockRanges.reserveCapacity(document.childCount)

        for child in document.children {
            guard let range = child.range,
                  let startIndex = stringIndex(
                      forLine: range.lowerBound.line,
                      column: range.lowerBound.column,
                      in: markdown
                  ),
                  let endIndex = stringIndex(
                      forLine: range.upperBound.line,
                      column: range.upperBound.column,
                      in: markdown
                  )
            else {
                return []
            }

            rootBlockRanges.append(
                RootBlockRange(
                    startIndex: startIndex,
                    endIndex: endIndex
                )
            )
        }

        return rootBlockRanges
    }

    func shiftRootBlockRanges(
        _ ranges: [RootBlockRange],
        from source: String,
        into destination: String,
        at destinationStartIndex: String.Index
    ) -> [RootBlockRange] {
        ranges.map { range in
            RootBlockRange(
                startIndex: shiftedIndex(
                    range.startIndex,
                    from: source,
                    into: destination,
                    at: destinationStartIndex
                ),
                endIndex: shiftedIndex(
                    range.endIndex,
                    from: source,
                    into: destination,
                    at: destinationStartIndex
                )
            )
        }
    }

    func shiftedIndex(
        _ index: String.Index,
        from source: String,
        into destination: String,
        at destinationStartIndex: String.Index
    ) -> String.Index {
        let offset = source.distance(from: source.startIndex, to: index)
        return destination.index(destinationStartIndex, offsetBy: offset)
    }

    func reparsedRootBlockIndex(
        in sourceText: String,
        rootBlockRanges: [RootBlockRange]
    ) -> Int {
        guard rootBlockRanges.isEmpty == false else {
            return 0
        }

        var reparsedRootBlockIndex = rootBlockRanges.count - 1

        while reparsedRootBlockIndex > 0 {
            let previousRootBlockRange = rootBlockRanges[reparsedRootBlockIndex - 1]
            let currentRootBlockRange = rootBlockRanges[reparsedRootBlockIndex]
            let separatorText = sourceText[
                previousRootBlockRange.endIndex..<currentRootBlockRange.startIndex
            ]

            if separatorText.contains("\n\n") {
                break
            }

            reparsedRootBlockIndex -= 1
        }

        return reparsedRootBlockIndex
    }

    func stringIndex(
        forLine targetLine: Int,
        column targetColumn: Int,
        in text: String
    ) -> String.Index? {
        guard targetLine > 0, targetColumn > 0 else { return nil }

        var currentLine = 1
        var lineStartIndex = text.startIndex

        while currentLine < targetLine {
            guard let newlineIndex = text[lineStartIndex...].firstIndex(of: "\n") else {
                return nil
            }
            lineStartIndex = text.index(after: newlineIndex)
            currentLine += 1
        }

        let targetOffset = targetColumn - 1
        let lineEndIndex: String.Index
        if let newlineIndex = text[lineStartIndex...].firstIndex(of: "\n") {
            lineEndIndex = newlineIndex
        } else {
            lineEndIndex = text.endIndex
        }

        let maximumOffset = text.distance(from: lineStartIndex, to: lineEndIndex)
        if targetOffset > maximumOffset {
            return lineEndIndex
        }

        return text.index(lineStartIndex, offsetBy: targetOffset)
    }
}
