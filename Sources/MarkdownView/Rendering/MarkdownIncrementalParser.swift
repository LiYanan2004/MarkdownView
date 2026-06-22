//
//  MarkdownIncrementalParser.swift
//  MarkdownView
//

import Foundation
import Markdown

struct MarkdownIncrementalParser {
    struct PreviousState {
        let sourceText: String
        let processedSourceText: String
        let document: Markdown.Document
        let configuration: MarkdownRendererConfiguration
        let mathContext: MarkdownMathContext?
        let parsesBlockDirectives: Bool
        let rootBlockRanges: [RootBlockRange]?
        let processedRootBlockRanges: [RootBlockRange]?
    }

    struct ParseResult {
        let renderingInput: MarkdownRenderingInput
        let rootBlockRanges: [RootBlockRange]?
        let processedSourceText: String
        let processedRootBlockRanges: [RootBlockRange]?
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
    struct PreparedParse {
        let renderingInput: MarkdownRenderingInput
        let processedSourceText: String
        let sourceRootBlockRanges: [RootBlockRange]
        let processedRootBlockRanges: [RootBlockRange]
    }

    func fullParse(
        sourceText: String,
        configuration: MarkdownRendererConfiguration,
        parsesBlockDirectives: Bool
    ) -> ParseResult {
        let preparedParse = prepareParse(
            sourceText: sourceText,
            configuration: configuration,
            parsesBlockDirectives: parsesBlockDirectives
        )
        return ParseResult(
            renderingInput: preparedParse.renderingInput,
            rootBlockRanges: preparedParse.sourceRootBlockRanges,
            processedSourceText: preparedParse.processedSourceText,
            processedRootBlockRanges: preparedParse.processedRootBlockRanges,
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
        guard let previousProcessedRanges = previousState.processedRootBlockRanges,
              previousProcessedRanges.isEmpty == false
        else {
            return nil
        }
        let reparsedProcessedStartIndex = previousProcessedRanges[reparsedRootBlockIndex].startIndex

        let stablePrefixText = previousSourceText[..<reparsedStartIndex]
        guard newSourceText.starts(with: stablePrefixText) else { return nil }

        let tailSourceText = String(newSourceText[reparsedStartIndex...])
        let tailPreparedParse = prepareParse(
            sourceText: tailSourceText,
            configuration: configuration,
            parsesBlockDirectives: parsesBlockDirectives
        )

        let mergedChildren = previousRootBlocks
            .prefix(stableRootBlockCount)
            .map(\.detachedFromParent)
            + Array(tailPreparedParse.renderingInput.document.children).map(\.detachedFromParent)
        guard let mergedDocument = previousState.document
            .withUncheckedChildren(mergedChildren) as? Markdown.Document
        else {
            return nil
        }

        let mergedProcessedSourceText = String(
            previousState.processedSourceText[..<reparsedProcessedStartIndex]
        ) + tailPreparedParse.processedSourceText
        let mergedRenderedConfiguration = mergedConfiguration(
            previousState: previousState,
            configuration: configuration,
            stablePrefixProcessedEndIndex: reparsedProcessedStartIndex,
            tailPreparedParse: tailPreparedParse
        )
        let mergedRanges = Array(previousRanges.prefix(stableRootBlockCount))
            + shiftRootBlockRanges(
                tailPreparedParse.sourceRootBlockRanges,
                from: tailSourceText,
                into: newSourceText,
                at: reparsedStartIndex
            )
        let mergedProcessedRanges = Array(previousProcessedRanges.prefix(stableRootBlockCount))
            + shiftRootBlockRanges(
                tailPreparedParse.processedRootBlockRanges,
                from: tailPreparedParse.processedSourceText,
                into: mergedProcessedSourceText,
                at: reparsedProcessedStartIndex
            )

        return ParseResult(
            renderingInput: MarkdownRenderingInput(
                document: mergedDocument,
                configuration: mergedRenderedConfiguration
            ),
            rootBlockRanges: mergedRanges,
            processedSourceText: mergedProcessedSourceText,
            processedRootBlockRanges: mergedProcessedRanges,
            usedIncrementalParsing: true,
            stablePrefixRootBlockCount: stableRootBlockCount
        )
    }

    func prepareParse(
        sourceText: String,
        configuration: MarkdownRendererConfiguration,
        parsesBlockDirectives: Bool
    ) -> PreparedParse {
        let parseOptions = MarkdownRenderingInput.parseOptions(
            configuration: configuration,
            parsesBlockDirectives: parsesBlockDirectives
        )

        if configuration.math.shouldRender,
           supportsMathRendering {
            let preprocessingResult = MarkdownMathPreprocessor()
                .preprocessingResult(for: sourceText)
            let processedSourceText = preprocessingResult.markdown
            let document = Markdown.Document(
                parsing: processedSourceText,
                options: parseOptions
            )
            let processedRootBlockRanges = parseRootBlockRanges(
                in: processedSourceText,
                document: document
            )
            let sourceRootBlockRanges = rawRootBlockRanges(
                from: processedRootBlockRanges,
                sourceText: sourceText,
                processedSourceText: processedSourceText,
                replacements: preprocessingResult.replacements
            )
            let renderedConfiguration = configuration
                .with(\.math.context, preprocessingResult.context)

            return PreparedParse(
                renderingInput: MarkdownRenderingInput(
                    document: document,
                    configuration: renderedConfiguration
                ),
                processedSourceText: processedSourceText,
                sourceRootBlockRanges: sourceRootBlockRanges,
                processedRootBlockRanges: processedRootBlockRanges
            )
        }

        let document = Markdown.Document(
            parsing: sourceText,
            options: parseOptions
        )
        let rootBlockRanges = parseRootBlockRanges(
            in: sourceText,
            document: document
        )

        return PreparedParse(
            renderingInput: MarkdownRenderingInput(
                document: document,
                configuration: configuration
            ),
            processedSourceText: sourceText,
            sourceRootBlockRanges: rootBlockRanges,
            processedRootBlockRanges: rootBlockRanges
        )
    }

    func mergedConfiguration(
        previousState: PreviousState,
        configuration: MarkdownRendererConfiguration,
        stablePrefixProcessedEndIndex: String.Index,
        tailPreparedParse: PreparedParse
    ) -> MarkdownRendererConfiguration {
        guard configuration.math.shouldRender,
              supportsMathRendering,
              let previousMathContext = previousState.mathContext,
              let tailMathContext = tailPreparedParse.renderingInput.configuration.math.context
        else {
            return tailPreparedParse.renderingInput.configuration
        }

        let stablePrefixProcessedText = previousState.processedSourceText[
            ..<stablePrefixProcessedEndIndex
        ]
        let stableMathContext = mathContext(
            from: previousMathContext,
            containedIn: stablePrefixProcessedText
        )

        return configuration.with(
            \.math.context,
            MarkdownMathContext(
                inlineMathStorage: stableMathContext.inlineMathStorage.merging(
                    tailMathContext.inlineMathStorage,
                    uniquingKeysWith: { _, tailValue in tailValue }
                ),
                displayMathStorage: stableMathContext.displayMathStorage.merging(
                    tailMathContext.displayMathStorage,
                    uniquingKeysWith: { _, tailValue in tailValue }
                )
            )
        )
    }

    func mathContext(
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

    func rawRootBlockRanges(
        from processedRootBlockRanges: [RootBlockRange],
        sourceText: String,
        processedSourceText: String,
        replacements: [MarkdownMathPreprocessor.Replacement]
    ) -> [RootBlockRange] {
        let sourceRootBlockRanges: [RootBlockRange] = processedRootBlockRanges.compactMap {
            range -> RootBlockRange? in
            guard let sourceStartIndex = sourceIndex(
                forProcessedIndex: range.startIndex,
                sourceText: sourceText,
                processedSourceText: processedSourceText,
                replacements: replacements
            ),
            let sourceEndIndex = sourceIndex(
                forProcessedIndex: range.endIndex,
                sourceText: sourceText,
                processedSourceText: processedSourceText,
                replacements: replacements
            ) else {
                return nil
            }

            return RootBlockRange(
                startIndex: sourceStartIndex,
                endIndex: sourceEndIndex
            )
        }

        guard sourceRootBlockRanges.count == processedRootBlockRanges.count else {
            return []
        }

        return sourceRootBlockRanges
    }

    func sourceIndex(
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

    func sourceOffset(
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

    var supportsMathRendering: Bool {
        #if canImport(SwiftMath)
        true
        #else
        false
        #endif
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
