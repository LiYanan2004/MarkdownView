//
//  MarkdownRenderPipeline.swift
//  MarkdownView
//
//  Created by Codex on 2026/2/6.
//

import SwiftUI
import Markdown
#if canImport(RichText)
import RichText
#endif

@MainActor
struct MarkdownRenderPipeline {
    var configuration: MarkdownRendererConfiguration

    func makeViewBody(content: MarkdownContent) -> AnyView {
        let preparedInput = prepareInput(for: content)
        let semanticVisitor = MarkdownSemanticVisitor(configuration: preparedInput.configuration)
        let semanticDocument = semanticVisitor.makeDocument(for: preparedInput.document)
        return makeViewBody(
            for: semanticDocument,
            configuration: preparedInput.configuration
        )
    }

    func makeViewBody(for markup: any Markup) -> AnyView {
        let semanticVisitor = MarkdownSemanticVisitor(configuration: configuration)
        let semanticDocument = semanticVisitor.makeDocument(for: markup)
        return makeViewBody(
            for: semanticDocument,
            configuration: configuration
        )
    }

    func makeViewBody(descendingInto markup: any Markup) -> AnyView {
        let semanticVisitor = MarkdownSemanticVisitor(configuration: configuration)
        let semanticDocument = MarkdownSemanticDocument(
            rootNodes: semanticVisitor.makeNodes(descendingInto: markup)
        )
        return makeViewBody(
            for: semanticDocument,
            configuration: configuration
        )
    }

    #if canImport(RichText)
    @available(iOS 26, macOS 26, *)
    func makeTextBody(content: MarkdownContent) -> AnyView {
        let preparedInput = prepareInput(for: content)
        let semanticVisitor = MarkdownSemanticVisitor(configuration: preparedInput.configuration)
        let semanticDocument = semanticVisitor.makeDocument(for: preparedInput.document)

        let subtreeRenderer = MarkdownSubtreeRenderer.pipelineBacked
        let textContentEmitter = MarkdownTextContentEmitter(
            configuration: preparedInput.configuration,
            subtreeRenderer: subtreeRenderer
        )
        let textContent = textContentEmitter.makeTextContent(for: semanticDocument)
        return AnyView(
            TextView {
                textContent
            }
            .environment(\.markdownRendererConfiguration, preparedInput.configuration)
            .environment(\.markdownSubtreeRenderer, subtreeRenderer)
        )
    }
    #endif
}

private extension MarkdownRenderPipeline {
    func makeViewBody(
        for semanticDocument: MarkdownSemanticDocument,
        configuration: MarkdownRendererConfiguration
    ) -> AnyView {
        let subtreeRenderer = MarkdownSubtreeRenderer.pipelineBacked
        let viewEmitter = MarkdownViewEmitter(
            configuration: configuration,
            subtreeRenderer: subtreeRenderer
        )
        let body = viewEmitter.makeBody(for: semanticDocument)
        return AnyView(
            body
                .environment(\.markdownRendererConfiguration, configuration)
                .environment(\.markdownSubtreeRenderer, subtreeRenderer)
        )
    }

    func prepareInput(for content: MarkdownContent) -> PreparedRenderingInput {
        let preprocessedContent = preprocessMathIfNeeded(content: content)
        let parseOptions = parseOptions(for: preprocessedContent.configuration)
        let document = preprocessedContent.content.document(options: parseOptions)
        return PreparedRenderingInput(
            document: document,
            configuration: preprocessedContent.configuration
        )
    }

    func parseOptions(
        for configuration: MarkdownRendererConfiguration
    ) -> ParseOptions {
        var parseOptions = ParseOptions()
        if !configuration.allowedBlockDirectiveRenderers.isEmpty {
            parseOptions.insert(.parseBlockDirectives)
        }
        return parseOptions
    }

    func preprocessMathIfNeeded(
        content: MarkdownContent
    ) -> (content: MarkdownContent, configuration: MarkdownRendererConfiguration) {
        guard configuration.rendersMath else {
            return (content, configuration)
        }

        var configuration = configuration
        var rawMarkdown = (try? content.markdown) ?? ""

        var parsingRangesExtractor = ParsingRangesExtractor()
        parsingRangesExtractor.visit(content.document())

        for range in parsingRangesExtractor.parsableRanges(in: rawMarkdown).reversed() {
            let segmentParser = MathParser(text: rawMarkdown[range])
            for representation in segmentParser.mathRepresentations.reversed() where !representation.kind.inline {
                let identifier = configuration.math.appendDisplayMath(rawMarkdown[representation.range])
                rawMarkdown.replaceSubrange(
                    representation.range,
                    with: "@math(uuid:\(identifier))"
                )
            }
        }

        return (
            MarkdownContent(.plainText(rawMarkdown)),
            configuration
        )
    }
}

private extension MarkdownRenderPipeline {
    struct PreparedRenderingInput {
        var document: Document
        var configuration: MarkdownRendererConfiguration
    }

    struct ParsingRangesExtractor: MarkupWalker {
        private var excludedRanges: [Range<SourceLocation>] = []

        func parsableRanges(in text: String) -> [Range<String.Index>] {
            var parsableRanges: [Range<String.Index>] = []
            let excludedRanges = self.excludedRanges.map {
                ($0.lowerBound.index(in: text)..<$0.upperBound.index(in: text))
            }

            let fullRange = text.startIndex..<text.endIndex
            let sortedExcludedRanges = excludedRanges.sorted { $0.lowerBound < $1.lowerBound }
            var currentStart = fullRange.lowerBound

            for excludedRange in sortedExcludedRanges {
                if currentStart < excludedRange.lowerBound {
                    parsableRanges.append(currentStart..<excludedRange.lowerBound)
                }
                currentStart = excludedRange.upperBound
            }

            if currentStart < fullRange.upperBound {
                parsableRanges.append(currentStart..<fullRange.upperBound)
            }

            return parsableRanges
        }

        mutating func defaultVisit(_ markup: any Markup) {
            descendInto(markup)
        }

        mutating func visitCodeBlock(_ codeBlock: CodeBlock) {
            guard let range = codeBlock.range else {
                return
            }
            excludedRanges.append(range)
        }
    }
}

private extension SourceLocation {
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
        let targetUTF8Index = string.utf8.index(
            utf8LineStart,
            offsetBy: byteOffset,
            limitedBy: string.utf8.endIndex
        ) ?? string.utf8.endIndex

        return targetUTF8Index.samePosition(in: string) ?? string.endIndex
    }
}
