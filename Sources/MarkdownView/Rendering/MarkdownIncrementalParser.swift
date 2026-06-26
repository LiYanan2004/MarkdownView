//
//  MarkdownIncrementalParser.swift
//  MarkdownView
//

import Foundation
import Markdown

struct MarkdownIncrementalParser {
    typealias State = ParseResult

    struct ParseOptions: OptionSet, Sendable, Hashable {
        let rawValue: UInt8

        static let rendersMath = ParseOptions(rawValue: 1 << 0)
        static let parsesBlockDirectives = ParseOptions(rawValue: 1 << 1)

        init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }

    enum ParsingStrategy: Sendable, Equatable {
        case full
        case incremental(stablePrefixRootBlockCount: Int)
    }
    
    struct ParseResult: Sendable {
        let sourceText: String
        let parseOptions: ParseOptions
        let document: Markdown.Document
        let renderingConfiguration: MarkdownRendererConfiguration
        let processedSourceText: String
        let rootBlockRanges: [RootBlockRange]
        let processedRootBlockRanges: [RootBlockRange]
        let mode: ParsingStrategy

        var state: Self { self }
        var mathContext: MarkdownMathContext? { renderingConfiguration.math.context }
    }

    struct RootBlockRange: Sendable {
        let startIndex: String.Index
        let endIndex: String.Index
    }

    func parse(
        sourceText: String,
        configuration: MarkdownRendererConfiguration,
        requiresBlockDirectiveParsing: Bool,
        previousState: ParseResult?
    ) -> ParseResult {
        let parseOptions = makeParseOptions(
            configuration: configuration,
            requiresBlockDirectiveParsing: requiresBlockDirectiveParsing
        )
        var result: ParseResult?

        if let previousState,
           previousState.parseOptions == parseOptions {
            result = parseIncremental(
                newSourceText: sourceText,
                configuration: configuration,
                parseOptions: parseOptions,
                requiresBlockDirectiveParsing: requiresBlockDirectiveParsing,
                previousState: previousState
            )
        }

        return result ?? fullParse(
            sourceText: sourceText,
            configuration: configuration,
            parseOptions: parseOptions,
            requiresBlockDirectiveParsing: requiresBlockDirectiveParsing
        )
    }
}

private extension MarkdownIncrementalParser {
    struct PreparedParse: Sendable {
        let document: Markdown.Document
        let renderingConfiguration: MarkdownRendererConfiguration
        let processedSourceText: String
        let sourceRootBlockRanges: [RootBlockRange]
        let processedRootBlockRanges: [RootBlockRange]
    }

    func fullParse(
        sourceText: String,
        configuration: MarkdownRendererConfiguration,
        parseOptions: ParseOptions,
        requiresBlockDirectiveParsing: Bool
    ) -> ParseResult {
        let preparedParse = prepareParse(
            sourceText: sourceText,
            configuration: configuration,
            requiresBlockDirectiveParsing: requiresBlockDirectiveParsing
        )
        return ParseResult(
            sourceText: sourceText,
            parseOptions: parseOptions,
            document: preparedParse.document,
            renderingConfiguration: preparedParse.renderingConfiguration,
            processedSourceText: preparedParse.processedSourceText,
            rootBlockRanges: preparedParse.sourceRootBlockRanges,
            processedRootBlockRanges: preparedParse.processedRootBlockRanges,
            mode: .full
        )
    }

    func parseIncremental(
        newSourceText: String,
        configuration: MarkdownRendererConfiguration,
        parseOptions: ParseOptions,
        requiresBlockDirectiveParsing: Bool,
        previousState: ParseResult
    ) -> ParseResult? {
        let previousSourceText = previousState.sourceText
        guard previousSourceText.isEmpty == false else { return nil }
        guard newSourceText.count > previousSourceText.count else { return nil }

        let previousRootBlocks = Array(previousState.document.children)
        guard previousRootBlocks.isEmpty == false else { return nil }

        let previousRanges = previousState.rootBlockRanges
        guard previousRanges.isEmpty == false else { return nil }

        let reparsedRootBlockIndex = reparsedRootBlockIndex(
            in: previousSourceText,
            rootBlockRanges: previousRanges
        )
        let stableRootBlockCount = reparsedRootBlockIndex
        let reparsedStartIndex = previousRanges[reparsedRootBlockIndex].startIndex
        let previousProcessedRanges = previousState.processedRootBlockRanges
        guard previousProcessedRanges.isEmpty == false else { return nil }
        let reparsedProcessedStartIndex = previousProcessedRanges[reparsedRootBlockIndex].startIndex

        let stablePrefixText = previousSourceText[..<reparsedStartIndex]
        guard newSourceText.starts(with: stablePrefixText) else { return nil }

        let tailSourceText = String(newSourceText[reparsedStartIndex...])
        let tailPreparedParse = prepareParse(
            sourceText: tailSourceText,
            configuration: configuration,
            sourceOffset: newSourceText.distance(
                from: newSourceText.startIndex,
                to: reparsedStartIndex
            ),
            requiresBlockDirectiveParsing: requiresBlockDirectiveParsing
        )

        let mergedChildren = previousRootBlocks
            .prefix(stableRootBlockCount)
            .map(\.detachedFromParent)
            + Array(tailPreparedParse.document.children).map(\.detachedFromParent)
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
            sourceText: newSourceText,
            parseOptions: parseOptions,
            document: mergedDocument,
            renderingConfiguration: mergedRenderedConfiguration,
            processedSourceText: mergedProcessedSourceText,
            rootBlockRanges: mergedRanges,
            processedRootBlockRanges: mergedProcessedRanges,
            mode: .incremental(stablePrefixRootBlockCount: stableRootBlockCount)
        )
    }

    func prepareParse(
        sourceText: String,
        configuration: MarkdownRendererConfiguration,
        sourceOffset: Int = 0,
        requiresBlockDirectiveParsing: Bool
    ) -> PreparedParse {
        let parseOptions = MarkdownRenderingInput.parseOptions(
            requiresBlockDirectiveParsing: requiresBlockDirectiveParsing
        )

        if configuration.math.shouldRender, supportsMathRendering {
            let preprocessingResult = MarkdownMathPreprocessor()
                .preprocessingResult(
                    for: sourceText,
                    requiresBlockDirectiveParsing: requiresBlockDirectiveParsing
                )
            let remappedPreprocessingResult = remappedMathPreprocessingResult(
                preprocessingResult,
                sourceOffset: sourceOffset
            )
            let processedSourceText = remappedPreprocessingResult.markdown
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
                replacements: remappedPreprocessingResult.replacements
            )
            let renderedConfiguration = configuration
                .with(\.math.context, remappedPreprocessingResult.context)

            return PreparedParse(
                document: document,
                renderingConfiguration: renderedConfiguration,
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
            document: document,
            renderingConfiguration: configuration,
            processedSourceText: sourceText,
            sourceRootBlockRanges: rootBlockRanges,
            processedRootBlockRanges: rootBlockRanges
        )
    }

    func mergedConfiguration(
        previousState: ParseResult,
        configuration: MarkdownRendererConfiguration,
        stablePrefixProcessedEndIndex: String.Index,
        tailPreparedParse: PreparedParse
    ) -> MarkdownRendererConfiguration {
        guard configuration.math.shouldRender,
              supportsMathRendering,
              let previousMathContext = previousState.mathContext,
              let tailMathContext = tailPreparedParse.renderingConfiguration.math.context
        else { return tailPreparedParse.renderingConfiguration }

        let stablePrefixProcessedText = previousState
            .processedSourceText[..<stablePrefixProcessedEndIndex]
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

    func makeParseOptions(
        configuration: MarkdownRendererConfiguration,
        requiresBlockDirectiveParsing: Bool
    ) -> ParseOptions {
        var parseOptions: ParseOptions = []
        if configuration.math.shouldRender, supportsMathRendering {
            parseOptions.insert(.rendersMath)
        }
        if requiresBlockDirectiveParsing {
            parseOptions.insert(.parsesBlockDirectives)
        }
        return parseOptions
    }

    func remappedMathPreprocessingResult(
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
