//
//  MarkdownDocumentParser.swift
//  MarkdownView
//

import Foundation
import Markdown

struct MarkdownDocumentParser {
    static func parse(
        _ input: MarkdownRenderingInput,
        previousState: ParseResult? = nil
    ) -> MarkdownRenderingOutput {
        let parseResult: ParseResult

        if let previousState,
           previousState.parseOptions == input.parsingOptions,
           let incrementalParseResult = parseIncremental(
                newSourceText: input.sourceText,
                parseOptions: input.parsingOptions,
                previousState: previousState
           ) {
            parseResult = incrementalParseResult
        } else {
            parseResult = fullParse(
                sourceText: input.sourceText,
                parseOptions: input.parsingOptions
            )
        }

        return MarkdownRenderingOutput(
            mathContext: parseResult.mathContext,
            parseResult: parseResult
        )
    }
}

extension MarkdownDocumentParser {
    enum ParsingStrategy: Sendable, Hashable {
        /// Reuses the previous parse result without additional parsing.
        case retained

        /// Performs incremental parsing.
        case incremental(stablePrefixRootBlockCount: Int)

        /// Performs a full parse.
        case full
    }
    
    struct ParseResult: Sendable {
        let sourceSnapshot: MarkdownSnapshot
        let processedSnapshot: MarkdownSnapshot
        var parseOptions: MarkdownDocumentParsingOptions
        var document: Markdown.Document
        var mathContext: MarkdownMathContext?
        var mode: ParsingStrategy
        
        func retained() -> ParseResult {
            var copy = self
            copy.mode = .retained
            return copy
        }
    }

    struct MarkdownSnapshot: Sendable {
        let text: String
        let blockRanges: [Range<String.Index>]
    }
}

extension MarkdownDocumentParser {
    static func fullParse(
        sourceText: String,
        parseOptions: MarkdownDocumentParsingOptions
    ) -> ParseResult {
        let preparedParse = prepareParse(
            sourceText: sourceText,
            parseOptions: parseOptions
        )
        return ParseResult(
            sourceSnapshot: preparedParse.sourceSnapshot,
            processedSnapshot: preparedParse.processedSnapshot,
            parseOptions: parseOptions,
            document: preparedParse.document,
            mathContext: preparedParse.mathContext,
            mode: .full
        )
    }

    static func parseIncremental(
        newSourceText: String,
        parseOptions: MarkdownDocumentParsingOptions,
        previousState: ParseResult
    ) -> ParseResult? {
        let previousSourceText = previousState.sourceSnapshot.text
        
        // Reuse previous state if the input text is the same
        if previousSourceText == newSourceText,
           parseOptions == previousState.parseOptions {
            return previousState.retained()
        }

        guard previousSourceText.isEmpty == false else { return nil }
        
        // Assume that the incremental parsing is always tail appending.
        guard newSourceText.hasPrefix(previousSourceText) else { return nil }

        let previousRootBlocks = Array(previousState.document.children)
        guard previousRootBlocks.isEmpty == false else { return nil }

        let previousRanges = previousState.sourceSnapshot.blockRanges
        guard previousRanges.isEmpty == false else { return nil }

        let reparsedRootBlockIndex = reparsedRootBlockIndex(
            in: previousSourceText,
            rootBlockRanges: previousRanges
        )
        let stableRootBlockCount = reparsedRootBlockIndex
        let reparsedStartIndex = previousRanges[reparsedRootBlockIndex].lowerBound
        let previousProcessedRanges = previousState.processedSnapshot.blockRanges
        guard previousProcessedRanges.isEmpty == false else { return nil }
        let reparsedProcessedStartIndex = previousProcessedRanges[reparsedRootBlockIndex].lowerBound

        let tailSourceText = String(newSourceText[reparsedStartIndex...])
        let tailPreparedParse = prepareParse(
            sourceText: tailSourceText,
            parseOptions: parseOptions,
            sourceOffset: newSourceText.distance(
                from: newSourceText.startIndex,
                to: reparsedStartIndex
            )
        )

        var mergedChildren = previousRootBlocks
            .prefix(stableRootBlockCount)
            .map(\.detachedFromParent)
        mergedChildren += tailPreparedParse.document.children.map(\.detachedFromParent)
        
        let mergedDocument = previousState.document
            .withUncheckedChildren(mergedChildren) as? Markdown.Document
        guard let mergedDocument else { return nil }

        let mergedProcessedSourceText: String = previousState.processedSnapshot.text[..<reparsedProcessedStartIndex] + tailPreparedParse.processedSnapshot.text
        let mergedMathContext = mergedMathContext(
            previousState: previousState,
            parseOptions: parseOptions,
            stablePrefixProcessedEndIndex: reparsedProcessedStartIndex,
            tailPreparedParse: tailPreparedParse
        )
        let mergedRanges = previousRanges.prefix(stableRootBlockCount) + shiftRootBlockRanges(
            tailPreparedParse.sourceSnapshot.blockRanges,
            from: tailSourceText,
            into: newSourceText,
            at: reparsedStartIndex
        )
        let mergedProcessedRanges = previousProcessedRanges.prefix(stableRootBlockCount) + shiftRootBlockRanges(
            tailPreparedParse.processedSnapshot.blockRanges,
            from: tailPreparedParse.processedSnapshot.text,
            into: mergedProcessedSourceText,
            at: reparsedProcessedStartIndex
        )

        return ParseResult(
            sourceSnapshot: MarkdownSnapshot(
                text: newSourceText,
                blockRanges: Array(mergedRanges)
            ),
            processedSnapshot: MarkdownSnapshot(
                text: mergedProcessedSourceText,
                blockRanges: Array(mergedProcessedRanges)
            ),
            parseOptions: parseOptions,
            document: mergedDocument,
            mathContext: mergedMathContext,
            mode: .incremental(stablePrefixRootBlockCount: stableRootBlockCount)
        )
    }
}

extension MarkdownDocumentParser {
    struct PreparedParse: Sendable {
        let document: Markdown.Document
        let sourceSnapshot: MarkdownSnapshot
        let processedSnapshot: MarkdownSnapshot
        let mathContext: MarkdownMathContext?
    }

    static func prepareParse(
        sourceText: String,
        parseOptions: MarkdownDocumentParsingOptions,
        sourceOffset: Int = 0,
    ) -> PreparedParse {
        let markdownParseOptions = parseOptions.markdownParseOptions

        if parseOptions.contains(.rendersMath) && canProcessMath {
            let preprocessingResult = MarkdownMathPreprocessor()
                .preprocessingResult(
                    for: sourceText,
                    requiresBlockDirectiveParsing: parseOptions.contains(.parsesBlockDirectives)
                )
            let remappedPreprocessingResult = remappedMathPreprocessingResult(
                preprocessingResult,
                sourceOffset: sourceOffset
            )
            let processedSourceText = remappedPreprocessingResult.markdown
            let document = Markdown.Document(
                parsing: processedSourceText,
                options: markdownParseOptions
            )
            let processedRootBlockRanges = parseRootBlockRanges(
                in: processedSourceText,
                document: document
            )
            let sourceRootBlockRanges = rawRootBlockRanges(
                from: processedRootBlockRanges,
                sourceText: sourceText,
                processedSourceText: processedSourceText,
                replacements: remappedPreprocessingResult.replacements
            )

            return PreparedParse(
                document: document,
                sourceSnapshot: MarkdownSnapshot(
                    text: sourceText,
                    blockRanges: sourceRootBlockRanges
                ),
                processedSnapshot: MarkdownSnapshot(
                    text: processedSourceText,
                    blockRanges: processedRootBlockRanges
                ),
                mathContext: remappedPreprocessingResult.context
            )
        }

        let document = Markdown.Document(
            parsing: sourceText,
            options: markdownParseOptions
        )
        let rootBlockRanges = parseRootBlockRanges(
            in: sourceText,
            document: document
        )

        return PreparedParse(
            document: document,
            sourceSnapshot: MarkdownSnapshot(
                text: sourceText,
                blockRanges: rootBlockRanges
            ),
            processedSnapshot: MarkdownSnapshot(
                text: sourceText,
                blockRanges: rootBlockRanges
            ),
            mathContext: nil
        )
    }

    static func mergedMathContext(
        previousState: ParseResult,
        parseOptions: MarkdownDocumentParsingOptions,
        stablePrefixProcessedEndIndex: String.Index,
        tailPreparedParse: PreparedParse
    ) -> MarkdownMathContext? {
        guard parseOptions.contains(.rendersMath) && canProcessMath,
              let previousMathContext = previousState.mathContext,
              let tailMathContext = tailPreparedParse.mathContext
        else { return tailPreparedParse.mathContext }

        let stablePrefixProcessedText = previousState
            .processedSnapshot.text[..<stablePrefixProcessedEndIndex]
        let stableMathContext = mathContext(
            from: previousMathContext,
            containedIn: stablePrefixProcessedText
        )

        let resolvedMathContext = MarkdownMathContext(
            inlineMathStorage: stableMathContext.inlineMathStorage.merging(
                tailMathContext.inlineMathStorage,
                uniquingKeysWith: { _, tailValue in tailValue }
            ),
            displayMathStorage: stableMathContext.displayMathStorage.merging(
                tailMathContext.displayMathStorage,
                uniquingKeysWith: { _, tailValue in tailValue }
            )
        )
        return resolvedMathContext
    }

    static func remappedMathPreprocessingResult(
        _ preprocessingResult: MarkdownMathPreprocessor.Result,
        sourceOffset: Int
    ) -> MarkdownMathPreprocessor.Result {
        guard sourceOffset > 0 else {
            return preprocessingResult
        }

        var processedSourceText = preprocessingResult.markdown
        var remappedInlineMathStorage: [UUID: String] = [:]
        var remappedDisplayMathStorage: [UUID: String] = [:]

        for replacement in preprocessingResult.replacements.reversed() {
            let placeholderStartIndex = processedSourceText.index(
                processedSourceText.startIndex,
                offsetBy: replacement.processedRange.lowerBound
            )
            let placeholderEndIndex = processedSourceText.index(
                processedSourceText.startIndex,
                offsetBy: replacement.processedRange.upperBound
            )
            let placeholder = String(
                processedSourceText[placeholderStartIndex..<placeholderEndIndex]
            )
            guard let placeholderMatch = MarkdownMathPreprocessor.placeholderMatch(in: placeholder) else {
                continue
            }

            let remappedIdentifier: UUID
            switch placeholderMatch.kind {
            case .inline:
                guard let matchedText = preprocessingResult.context.inlineMathStorage[placeholderMatch.identifier] else {
                    continue
                }
                remappedIdentifier = MarkdownMathPreprocessor.stableIdentifier(
                    matchedText: matchedText,
                    sourceRange: (replacement.sourceRange.lowerBound + sourceOffset)..<(replacement.sourceRange.upperBound + sourceOffset)
                )
                remappedInlineMathStorage[remappedIdentifier] = matchedText
            case .display:
                guard let matchedText = preprocessingResult.context.displayMathStorage[placeholderMatch.identifier] else {
                    continue
                }
                remappedIdentifier = MarkdownMathPreprocessor.stableIdentifier(
                    matchedText: matchedText,
                    sourceRange: (replacement.sourceRange.lowerBound + sourceOffset)..<(replacement.sourceRange.upperBound + sourceOffset)
                )
                remappedDisplayMathStorage[remappedIdentifier] = matchedText
            }

            let remappedPlaceholder = MarkdownMathPreprocessor.placeholder(
                for: remappedIdentifier,
                kind: placeholderMatch.kind
            )
            processedSourceText.replaceSubrange(
                placeholderStartIndex..<placeholderEndIndex,
                with: remappedPlaceholder
            )
        }

        return MarkdownMathPreprocessor.Result(
            markdown: processedSourceText,
            context: MarkdownMathContext(
                inlineMathStorage: remappedInlineMathStorage,
                displayMathStorage: remappedDisplayMathStorage
            ),
            replacements: preprocessingResult.replacements
        )
    }

    static func mathContext(
        from context: MarkdownMathContext,
        containedIn processedSourceText: Substring
    ) -> MarkdownMathContext {
        let inlineMathStorage = context.inlineMathStorage.filter { identifier, _ in
            processedSourceText.contains(
                MarkdownMathPreprocessor.inlinePlaceholder(for: identifier)
            )
        }
        let displayMathStorage = context.displayMathStorage.filter { identifier, _ in
            processedSourceText.contains(
                MarkdownMathPreprocessor.displayPlaceholder(for: identifier)
            )
        }

        return MarkdownMathContext(
            inlineMathStorage: inlineMathStorage,
            displayMathStorage: displayMathStorage
        )
    }

    static func rawRootBlockRanges(
        from processedRootBlockRanges: [Range<String.Index>],
        sourceText: String,
        processedSourceText: String,
        replacements: [MarkdownMathPreprocessor.Replacement]
    ) -> [Range<String.Index>] {
        let sourceRootBlockRanges: [Range<String.Index>] = processedRootBlockRanges.compactMap {
            range -> Range<String.Index>? in
            guard let sourceStartIndex = sourceIndex(
                forProcessedIndex: range.lowerBound,
                sourceText: sourceText,
                processedSourceText: processedSourceText,
                replacements: replacements
            ),
            let sourceEndIndex = sourceIndex(
                forProcessedIndex: range.upperBound,
                sourceText: sourceText,
                processedSourceText: processedSourceText,
                replacements: replacements
            ) else {
                return nil
            }

            return sourceStartIndex..<sourceEndIndex
        }

        guard sourceRootBlockRanges.count == processedRootBlockRanges.count else {
            return []
        }

        return sourceRootBlockRanges
    }

    static func sourceIndex(
        forProcessedIndex processedIndex: String.Index,
        sourceText: String,
        processedSourceText: String,
        replacements: [MarkdownMathPreprocessor.Replacement]
    ) -> String.Index? {
        let processedOffset = processedSourceText.distance(
            from: processedSourceText.startIndex,
            to: processedIndex
        )
        guard let sourceOffset = sourceOffset(
            forProcessedOffset: processedOffset,
            replacements: replacements
        ) else {
            return nil
        }
        return sourceText.index(sourceText.startIndex, offsetBy: sourceOffset)
    }

    static func sourceOffset(
        forProcessedOffset processedOffset: Int,
        replacements: [MarkdownMathPreprocessor.Replacement]
    ) -> Int? {
        var sourceOffset = processedOffset

        for replacement in replacements {
            if processedOffset < replacement.processedRange.lowerBound {
                break
            }

            if processedOffset <= replacement.processedRange.upperBound {
                if processedOffset == replacement.processedRange.lowerBound {
                    return replacement.sourceRange.lowerBound
                }
                if processedOffset == replacement.processedRange.upperBound {
                    return replacement.sourceRange.upperBound
                }
                return nil
            }

            sourceOffset += replacement.sourceRange.count - replacement.processedRange.count
        }

        return sourceOffset
    }

    static var canProcessMath: Bool {
        #if LaTeX && canImport(SwiftMath)
        true
        #else
        false
        #endif
    }
    static func parseRootBlockRanges(
        in markdown: String,
        document: Markdown.Document
    ) -> [Range<String.Index>] {
        var rootBlockRanges: [Range<String.Index>] = []
        rootBlockRanges.reserveCapacity(document.childCount)

        for child in document.children {
            guard let range = child.range,
                  let startIndex = markdown.stringIndex(
                      forLine: range.lowerBound.line,
                      column: range.lowerBound.column
                  ),
                  let endIndex = markdown.stringIndex(
                      forLine: range.upperBound.line,
                      column: range.upperBound.column
                  )
            else { return [] }

            rootBlockRanges.append(
                startIndex..<endIndex
            )
        }

        return rootBlockRanges
    }

    static func shiftRootBlockRanges(
        _ ranges: [Range<String.Index>],
        from source: String,
        into destination: String,
        at destinationStartIndex: String.Index
    ) -> [Range<String.Index>] {
        ranges.map { range in
            shiftedIndex(
                range.lowerBound,
                from: source,
                into: destination,
                at: destinationStartIndex
            )..<shiftedIndex(
                range.upperBound,
                from: source,
                into: destination,
                at: destinationStartIndex
            )
        }
    }

    static func shiftedIndex(
        _ index: String.Index,
        from source: String,
        into destination: String,
        at destinationStartIndex: String.Index
    ) -> String.Index {
        let offset = source.distance(from: source.startIndex, to: index)
        return destination.index(destinationStartIndex, offsetBy: offset)
    }

    static func reparsedRootBlockIndex(
        in sourceText: String,
        rootBlockRanges: [Range<String.Index>]
    ) -> Int {
        guard rootBlockRanges.isEmpty == false else {
            return 0
        }

        var reparsedRootBlockIndex = rootBlockRanges.count - 1

        while reparsedRootBlockIndex > 0 {
            let previousRootBlockRange = rootBlockRanges[reparsedRootBlockIndex - 1]
            let currentRootBlockRange = rootBlockRanges[reparsedRootBlockIndex]
            let separatorText = sourceText[
                previousRootBlockRange.upperBound..<currentRootBlockRange.lowerBound
            ]

            if separatorText.contains("\n\n") {
                break
            }

            reparsedRootBlockIndex -= 1
        }

        return reparsedRootBlockIndex
    }

    
}

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
