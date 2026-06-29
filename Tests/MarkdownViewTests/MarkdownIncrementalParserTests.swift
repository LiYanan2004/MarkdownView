//
//  MarkdownIncrementalParserTests.swift
//  MarkdownView
//
//  Created by Codex on 2026/6/22.
//

import Markdown
import SwiftUI
import Testing

@testable import MarkdownView

@Suite("Markdown Incremental Parser")
struct MarkdownIncrementalParserTests {
    @Test("Uses incremental parsing for trailing plain text append")
    func usesIncrementalParsingForTrailingPlainTextAppend() {
        let paragraphs = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
        let previous = paragraphs.joined(separator: "\n\n")
        let new = previous + " extended"

        let previousResult = makeParseResult(markdown: previous)
        let result = MarkdownDocumentParser.parse(
            parseRequest(markdown: new),
            previousState: previousResult
        )

        #expect(result.mode == .incremental(stablePrefixRootBlockCount: 5))
        #expect(documentDebugDescription(result.document) == fullParseDocumentDescription(markdown: new))
    }

    @Test("Reparses the last root block for closed code fence append")
    func reparsesTheLastRootBlockForClosedCodeFenceAppend() {
        let paragraphs = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
        let previous = paragraphs.joined(separator: "\n\n")
        let new = previous + "\n\n```swift\nlet value = 1\n```"

        let previousResult = makeParseResult(markdown: previous)
        let result = MarkdownDocumentParser.parse(
            parseRequest(markdown: new),
            previousState: previousResult
        )

        #expect(result.mode == .incremental(stablePrefixRootBlockCount: 5))
        #expect(documentDebugDescription(result.document) == fullParseDocumentDescription(markdown: new))
    }

    @Test("Reparses the last root block for open code fence append")
    func reparsesTheLastRootBlockForOpenCodeFenceAppend() {
        let paragraphs = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
        let previous = paragraphs.joined(separator: "\n\n")
        let new = previous + "\n\n```swift\nlet value = 1"

        let previousResult = makeParseResult(markdown: previous)
        let result = MarkdownDocumentParser.parse(
            parseRequest(markdown: new),
            previousState: previousResult
        )

        #expect(result.mode == .incremental(stablePrefixRootBlockCount: 5))
        #expect(documentDebugDescription(result.document) == fullParseDocumentDescription(markdown: new))
    }

    @Test("Reparses the last root block for list continuation")
    func reparsesTheLastRootBlockForListContinuation() {
        let paragraphs = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
        let previous = paragraphs.joined(separator: "\n\n")
        let new = previous + "\n\n- item"

        let previousResult = makeParseResult(markdown: previous)
        let result = MarkdownDocumentParser.parse(
            parseRequest(markdown: new),
            previousState: previousResult
        )

        #expect(result.mode == .incremental(stablePrefixRootBlockCount: 5))
        #expect(documentDebugDescription(result.document) == fullParseDocumentDescription(markdown: new))
    }

    @Test("Reparses the trailing table for the first table body row")
    func reparsesTheTrailingTableForTheFirstTableBodyRow() {
        let paragraphs = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
        let base = paragraphs.joined(separator: "\n\n")
        let previous = base + "\n\n| Name | Language |\n| --- | --- |"
        let new = previous + "\n| Swift | Native |"

        let previousResult = makeParseResult(markdown: previous)
        let result = MarkdownDocumentParser.parse(
            parseRequest(markdown: new),
            previousState: previousResult
        )

        #expect(result.mode == .incremental(stablePrefixRootBlockCount: 6))
        #expect(documentDebugDescription(result.document) == fullParseDocumentDescription(markdown: new))
    }

    @Test("Falls back for another trailing table body row")
    func fallsBackForAnotherTrailingTableBodyRow() {
        let paragraphs = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
        let base = paragraphs.joined(separator: "\n\n")
        let previous = base + """

        | Name | Language |
        | --- | --- |
        | Swift | Native |
        """
        let new = previous + "\n| Rust | Systems |"

        let previousResult = makeParseResult(markdown: previous)
        let result = MarkdownDocumentParser.parse(
            parseRequest(markdown: new),
            previousState: previousResult
        )

        #expect(result.mode == .full)
        #expect(documentDebugDescription(result.document) == fullParseDocumentDescription(markdown: new))
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
        let result = MarkdownDocumentParser.parse(
            parseRequest(markdown: new),
            previousState: previousResult
        )

        #expect(result.mode == .incremental(stablePrefixRootBlockCount: 1))
        #expect(documentDebugDescription(result.document) == fullParseDocumentDescription(markdown: new))
    }

    @Test("Falls back when an edit touches the stable prefix")
    func fallsBackWhenEditTouchesStablePrefix() {
        let previous = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
            .joined(separator: "\n\n")
        let new = ["Alpha updated", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
            .joined(separator: "\n\n")

        let previousResult = makeParseResult(markdown: previous)
        let result = MarkdownDocumentParser.parse(
            parseRequest(markdown: new),
            previousState: previousResult
        )

        #expect(result.mode == .full)
        #expect(documentDebugDescription(result.document) == fullParseDocumentDescription(markdown: new))
    }

    @Test("Falls back for deletion")
    func fallsBackForDeletion() {
        let previous = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
            .joined(separator: "\n\n")
        let new = ["Alpha", "Bravo", "Charlie", "Delta", "Echo"]
            .joined(separator: "\n\n")

        let previousResult = makeParseResult(markdown: previous)
        let result = MarkdownDocumentParser.parse(
            parseRequest(markdown: new),
            previousState: previousResult
        )

        #expect(result.mode == .full)
        #expect(documentDebugDescription(result.document) == fullParseDocumentDescription(markdown: new))
    }

    @Test("Uses incremental parsing for identical resend")
    func usesIncrementalParsingForIdenticalResend() {
        let markdown = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
            .joined(separator: "\n\n")

        let previousResult = makeParseResult(markdown: markdown)
        let result = MarkdownDocumentParser.parse(
            parseRequest(markdown: markdown),
            previousState: previousResult
        )

        #expect(result.mode == .retained)
        #expect(documentDebugDescription(result.document) == fullParseDocumentDescription(markdown: markdown))
    }

    #if ENABLE_MATH_RENDERING
    @Test("Uses incremental parsing when math rendering is enabled for inline math")
    func usesIncrementalParsingWhenMathRenderingIsEnabledForInlineMath() {
        let previous = "Inline math: $x$\n\nBravo"
        let new = previous + "\n\nTrailing math: $y$"

        let previousResult = MarkdownDocumentParser.parse(
            parseRequest(markdown: previous, mathContext: MarkdownMathContext())
        )
        let result = MarkdownDocumentParser.parse(
            parseRequest(markdown: new, mathContext: MarkdownMathContext()),
            previousState: previousResult
        )

        #expect(result.mode == MarkdownParseResult.ParsingStrategy.incremental(stablePrefixRootBlockCount: 1))
        #expect(result.mathContext?.inlineMathStorage.count == 2)
        #expect(result.mathContext?.inlineMathStorage.values.contains("$x$") == true)
        #expect(result.mathContext?.inlineMathStorage.values.contains("$y$") == true)
        #expect(documentDebugDescription(result.document) == fullParseDocumentDescription(
            markdown: new,
            mathContext: MarkdownMathContext(),
            requiresBlockDirectiveParsing: false
        ))
    }

    @Test("Uses incremental parsing when math rendering is enabled for display math")
    func usesIncrementalParsingWhenMathRenderingIsEnabledForDisplayMath() {
        let previous = """
        Alpha

        $$
        x
        $$
        """
        let new = previous + """

        $$
        y
        $$
        """
        let previousResult = MarkdownDocumentParser.parse(
            parseRequest(markdown: previous, mathContext: MarkdownMathContext())
        )
        let result = MarkdownDocumentParser.parse(
            parseRequest(markdown: new, mathContext: MarkdownMathContext()),
            previousState: previousResult
        )

        #expect(result.mode == MarkdownParseResult.ParsingStrategy.incremental(stablePrefixRootBlockCount: 1))
        #expect(result.mathContext?.displayMathStorage.count == 2)
        #expect(result.mathContext?.displayMathStorage.values.contains("$$\nx\n$$") == true)
        #expect(result.mathContext?.displayMathStorage.values.contains("$$\ny\n$$") == true)
        #expect(documentDebugDescription(result.document) == fullParseDocumentDescription(
            markdown: new,
            mathContext: MarkdownMathContext(),
            requiresBlockDirectiveParsing: false
        ))
    }
    #endif

    @Test("Preserves a streamed emoji tail")
    func preservesAStreamedEmojiTail() {
        assertStreamingMatchesFullParse(markdown: """
        # Title

        Final line with emoji: 😀 🚀 ✨
        """)
    }

    @Test("Preserves a streamed CJK tail")
    func preservesAStreamedCJKTail() {
        assertStreamingMatchesFullParse(markdown: """
        # 标题

        最后一行包含中文字符：叶子与结果
        """)
    }

    @MainActor
    @Test("Parses from detached work without main-actor isolation")
    func parsesFromDetachedWorkWithoutMainActorIsolation() async {
        let request = parseRequest(markdown: "# Title\n\nBody")

        let parseResult = await Task.detached(priority: .userInitiated) {
            MarkdownDocumentParser.parse(request)
        }.value

        #expect(parseResult.mode == .full)
        #expect(documentDebugDescription(parseResult.document) == fullParseDocumentDescription(markdown: "# Title\n\nBody"))
    }
}

private extension MarkdownIncrementalParserTests {
    func makeParseResult(
        markdown: String,
        mathContext: MarkdownMathContext? = nil,
        requiresBlockDirectiveParsing: Bool = false
    ) -> MarkdownParseResult {
        MarkdownDocumentParser.parse(
            parseRequest(
                markdown: markdown,
                mathContext: mathContext,
                requiresBlockDirectiveParsing: requiresBlockDirectiveParsing
            )
        )
    }

    func fullParseDocumentDescription(
        markdown: String,
        mathContext: MarkdownMathContext? = nil,
        requiresBlockDirectiveParsing: Bool = false
    ) -> String {
        let parseResult = MarkdownDocumentParser.parse(
            parseRequest(
                markdown: markdown,
                mathContext: mathContext,
                requiresBlockDirectiveParsing: requiresBlockDirectiveParsing
            )
        )
        return documentDebugDescription(parseResult.document)
    }

    func documentDebugDescription(_ document: Markdown.Document) -> String {
        document.debugDescription()
    }

    func assertStreamingMatchesFullParse(
        markdown: String,
        mathContext: MarkdownMathContext? = nil,
        requiresBlockDirectiveParsing: Bool = false
    ) {
        var streamedText = ""
        var previousState: MarkdownParseResult?

        for character in markdown {
            streamedText.append(character)

            let result = MarkdownDocumentParser.parse(
                parseRequest(
                    markdown: streamedText,
                    mathContext: mathContext,
                    requiresBlockDirectiveParsing: requiresBlockDirectiveParsing
                ),
                previousState: previousState
            )

            #expect(documentDebugDescription(result.document) == fullParseDocumentDescription(
                markdown: streamedText,
                mathContext: mathContext,
                requiresBlockDirectiveParsing: requiresBlockDirectiveParsing
            ))

            previousState = result
        }
    }

    func parseRequest(
        markdown: String,
        mathContext: MarkdownMathContext? = nil,
        requiresBlockDirectiveParsing: Bool = false
    ) -> MarkdownParseRequest {
        let elementRenderers: [MarkdownElementRendererRegistration]
        if requiresBlockDirectiveParsing {
            elementRenderers = [
                .blockDirective(IncrementalParserTestBlockDirectiveRenderer(), name: "Note")
            ]
        } else {
            elementRenderers = []
        }

        return MarkdownParseRequest(
            sourceText: markdown,
            mathContext: mathContext,
            elementRenderers: elementRenderers
        )
    }
}

private struct IncrementalParserTestBlockDirectiveRenderer: MarkdownBlockDirectiveRenderer {
    func makeBody(configuration: MarkdownBlockDirectiveRendererConfiguration) -> some View {
        EmptyView()
    }
}
