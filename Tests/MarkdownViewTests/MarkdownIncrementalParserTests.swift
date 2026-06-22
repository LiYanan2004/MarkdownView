//
//  MarkdownIncrementalParserTests.swift
//  MarkdownView
//
//  Created by Codex on 2026/6/22.
//

import Markdown
import Testing

@testable import MarkdownView

@Suite("Markdown Incremental Parser")
struct MarkdownIncrementalParserTests {
    private let incrementalParser = MarkdownIncrementalParser()

    @Test("Uses incremental parsing for trailing plain text append")
    func usesIncrementalParsingForTrailingPlainTextAppend() {
        let paragraphs = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
        let previous = paragraphs.joined(separator: "\n\n")
        let new = previous + " extended"

        let previousResult = makeParseResult(markdown: previous)
        let result = incrementalParser.parse(
            sourceText: new,
            configuration: .init(),
            parsesBlockDirectives: false,
            previousState: makePreviousState(
                sourceText: previous,
                parseResult: previousResult
            )
        )

        #expect(result.usedIncrementalParsing)
        #expect(result.stablePrefixRootBlockCount == 5)
        #expect(documentDebugDescription(result.renderingInput.document) == fullParseDocumentDescription(markdown: new))
    }

    @Test("Reparses the last root block for closed code fence append")
    func reparsesTheLastRootBlockForClosedCodeFenceAppend() {
        let paragraphs = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
        let previous = paragraphs.joined(separator: "\n\n")
        let new = previous + "\n\n```swift\nlet value = 1\n```"

        let previousResult = makeParseResult(markdown: previous)
        let result = incrementalParser.parse(
            sourceText: new,
            configuration: .init(),
            parsesBlockDirectives: false,
            previousState: makePreviousState(
                sourceText: previous,
                parseResult: previousResult
            )
        )

        #expect(result.usedIncrementalParsing)
        #expect(result.stablePrefixRootBlockCount == 5)
        #expect(documentDebugDescription(result.renderingInput.document) == fullParseDocumentDescription(markdown: new))
    }

    @Test("Reparses the last root block for open code fence append")
    func reparsesTheLastRootBlockForOpenCodeFenceAppend() {
        let paragraphs = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
        let previous = paragraphs.joined(separator: "\n\n")
        let new = previous + "\n\n```swift\nlet value = 1"

        let previousResult = makeParseResult(markdown: previous)
        let result = incrementalParser.parse(
            sourceText: new,
            configuration: .init(),
            parsesBlockDirectives: false,
            previousState: makePreviousState(
                sourceText: previous,
                parseResult: previousResult
            )
        )

        #expect(result.usedIncrementalParsing)
        #expect(result.stablePrefixRootBlockCount == 5)
        #expect(documentDebugDescription(result.renderingInput.document) == fullParseDocumentDescription(markdown: new))
    }

    @Test("Reparses the last root block for list continuation")
    func reparsesTheLastRootBlockForListContinuation() {
        let paragraphs = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
        let previous = paragraphs.joined(separator: "\n\n")
        let new = previous + "\n\n- item"

        let previousResult = makeParseResult(markdown: previous)
        let result = incrementalParser.parse(
            sourceText: new,
            configuration: .init(),
            parsesBlockDirectives: false,
            previousState: makePreviousState(
                sourceText: previous,
                parseResult: previousResult
            )
        )

        #expect(result.usedIncrementalParsing)
        #expect(result.stablePrefixRootBlockCount == 5)
        #expect(documentDebugDescription(result.renderingInput.document) == fullParseDocumentDescription(markdown: new))
    }

    @Test("Reparses the trailing table for the first table body row")
    func reparsesTheTrailingTableForTheFirstTableBodyRow() {
        let paragraphs = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
        let base = paragraphs.joined(separator: "\n\n")
        let previous = base + "\n\n| Name | Language |\n| --- | --- |"
        let new = previous + "\n| Swift | Native |"

        let previousResult = makeParseResult(markdown: previous)
        let result = incrementalParser.parse(
            sourceText: new,
            configuration: .init(),
            parsesBlockDirectives: false,
            previousState: makePreviousState(
                sourceText: previous,
                parseResult: previousResult
            )
        )

        #expect(result.usedIncrementalParsing)
        #expect(result.stablePrefixRootBlockCount == 6)
        #expect(documentDebugDescription(result.renderingInput.document) == fullParseDocumentDescription(markdown: new))
    }

    @Test("Reparses the trailing table for another table body row")
    func reparsesTheTrailingTableForAnotherTableBodyRow() {
        let paragraphs = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
        let base = paragraphs.joined(separator: "\n\n")
        let previous = base + """

        | Name | Language |
        | --- | --- |
        | Swift | Native |
        """
        let new = previous + "\n| Rust | Systems |"

        let previousResult = makeParseResult(markdown: previous)
        let result = incrementalParser.parse(
            sourceText: new,
            configuration: .init(),
            parsesBlockDirectives: false,
            previousState: makePreviousState(
                sourceText: previous,
                parseResult: previousResult
            )
        )

        #expect(result.usedIncrementalParsing)
        #expect(result.stablePrefixRootBlockCount == 6)
        #expect(documentDebugDescription(result.renderingInput.document) == fullParseDocumentDescription(markdown: new))
    }

    @Test("Reparses the whole trailing table when a partial body row becomes a valid table row")
    func reparsesTheWholeTrailingTableWhenAPartialBodyRowBecomesAValidTableRow() {
        let previous = """
        ## Tables

        | Name | Language | Platform | Notes |
        |:-----|:--------:|---------:|------|
        | 
        """
        let new = previous + "Swift"

        let previousResult = makeParseResult(markdown: previous)
        let result = incrementalParser.parse(
            sourceText: new,
            configuration: .init(),
            parsesBlockDirectives: false,
            previousState: makePreviousState(
                sourceText: previous,
                parseResult: previousResult
            )
        )

        #expect(result.usedIncrementalParsing)
        #expect(result.stablePrefixRootBlockCount == 1)
        #expect(documentDebugDescription(result.renderingInput.document) == fullParseDocumentDescription(markdown: new))
    }

    @Test("Falls back when an edit touches the stable prefix")
    func fallsBackWhenEditTouchesStablePrefix() {
        let previous = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
            .joined(separator: "\n\n")
        let new = ["Alpha updated", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
            .joined(separator: "\n\n")

        let previousResult = makeParseResult(markdown: previous)
        let result = incrementalParser.parse(
            sourceText: new,
            configuration: .init(),
            parsesBlockDirectives: false,
            previousState: makePreviousState(
                sourceText: previous,
                parseResult: previousResult
            )
        )

        #expect(result.usedIncrementalParsing == false)
        #expect(result.stablePrefixRootBlockCount == nil)
        #expect(documentDebugDescription(result.renderingInput.document) == fullParseDocumentDescription(markdown: new))
    }

    @Test("Falls back for deletion")
    func fallsBackForDeletion() {
        let previous = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
            .joined(separator: "\n\n")
        let new = ["Alpha", "Bravo", "Charlie", "Delta", "Echo"]
            .joined(separator: "\n\n")

        let previousResult = makeParseResult(markdown: previous)
        let result = incrementalParser.parse(
            sourceText: new,
            configuration: .init(),
            parsesBlockDirectives: false,
            previousState: makePreviousState(
                sourceText: previous,
                parseResult: previousResult
            )
        )

        #expect(result.usedIncrementalParsing == false)
        #expect(result.stablePrefixRootBlockCount == nil)
        #expect(documentDebugDescription(result.renderingInput.document) == fullParseDocumentDescription(markdown: new))
    }

    @Test("Falls back for identical resend")
    func fallsBackForIdenticalResend() {
        let markdown = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
            .joined(separator: "\n\n")

        let previousResult = makeParseResult(markdown: markdown)
        let result = incrementalParser.parse(
            sourceText: markdown,
            configuration: .init(),
            parsesBlockDirectives: false,
            previousState: makePreviousState(
                sourceText: markdown,
                parseResult: previousResult
            )
        )

        #expect(result.usedIncrementalParsing == false)
        #expect(result.stablePrefixRootBlockCount == nil)
        #expect(documentDebugDescription(result.renderingInput.document) == fullParseDocumentDescription(markdown: markdown))
    }

    @Test("Falls back when math rendering is enabled")
    func fallsBackWhenMathRenderingIsEnabled() {
        let previous = "Alpha\n\nBravo"
        let new = previous + "\n\nInline math: $x$"
        let configuration = MarkdownRendererConfiguration()
            .with(\.math.shouldRender, true)

        let previousResult = incrementalParser.parse(
            sourceText: previous,
            configuration: configuration,
            parsesBlockDirectives: true,
            previousState: nil
        )
        let result = incrementalParser.parse(
            sourceText: new,
            configuration: configuration,
            parsesBlockDirectives: true,
            previousState: makePreviousState(
                sourceText: previous,
                parseResult: previousResult
            )
        )

        #expect(result.usedIncrementalParsing == false)
        #expect(result.stablePrefixRootBlockCount == nil)
        #expect(documentDebugDescription(result.renderingInput.document) == fullParseDocumentDescription(
            markdown: new,
            configuration: configuration,
            parsesBlockDirectives: true
        ))
    }
}

private extension MarkdownIncrementalParserTests {
    func makeParseResult(
        markdown: String,
        configuration: MarkdownRendererConfiguration = .init(),
        parsesBlockDirectives: Bool = false
    ) -> MarkdownIncrementalParser.ParseResult {
        incrementalParser.parse(
            sourceText: markdown,
            configuration: configuration,
            parsesBlockDirectives: parsesBlockDirectives,
            previousState: nil
        )
    }

    func makePreviousState(
        sourceText: String,
        parseResult: MarkdownIncrementalParser.ParseResult,
        configuration: MarkdownRendererConfiguration = .init(),
        parsesBlockDirectives: Bool = false
    ) -> MarkdownIncrementalParser.PreviousState {
        MarkdownIncrementalParser.PreviousState(
            sourceText: sourceText,
            document: parseResult.renderingInput.document,
            configuration: configuration,
            parsesBlockDirectives: parsesBlockDirectives,
            rootBlockRanges: parseResult.rootBlockRanges
        )
    }

    func fullParseDocumentDescription(
        markdown: String,
        configuration: MarkdownRendererConfiguration = .init(),
        parsesBlockDirectives: Bool = false
    ) -> String {
        let renderingInput = MarkdownRenderingInput(
            source: .rawText(markdown),
            configuration: configuration,
            parsesBlockDirectives: parsesBlockDirectives
        )
        return documentDebugDescription(renderingInput.document)
    }

    func documentDebugDescription(_ document: Markdown.Document) -> String {
        document.debugDescription()
    }
}
