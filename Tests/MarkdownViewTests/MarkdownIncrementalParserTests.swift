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
    @Test(
        "Uses incremental parsing for a trailing plain-text append",
        .tags(.parsing, .incrementalParsing)
    )
    func usesIncrementalParsingForTrailingPlainTextAppend() {
        let paragraphs = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
        let previous = paragraphs.joined(separator: "\n\n")
        let new = previous + " extended"

        let previousResult = MarkdownViewTestSupport.makeParseResult(markdown: previous)
        let result = MarkdownDocumentParser.parse(
            MarkdownViewTestSupport.makeParseRequest(markdown: new),
            previousState: previousResult
        )

        #expect(result.parsingStrategy == .incremental(stablePrefixRootBlockCount: 5))
        #expect(
            MarkdownViewTestSupport.documentDebugDescription(result.document)
                == MarkdownViewTestSupport.fullParseDocumentDescription(markdown: new)
        )
    }

    @Test(
        "Reparses the last root block for a closed code-fence append",
        .tags(.parsing, .incrementalParsing)
    )
    func reparsesTheLastRootBlockForClosedCodeFenceAppend() {
        let paragraphs = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
        let previous = paragraphs.joined(separator: "\n\n")
        let new = previous + "\n\n```swift\nlet value = 1\n```"

        let previousResult = MarkdownViewTestSupport.makeParseResult(markdown: previous)
        let result = MarkdownDocumentParser.parse(
            MarkdownViewTestSupport.makeParseRequest(markdown: new),
            previousState: previousResult
        )

        #expect(result.parsingStrategy == .incremental(stablePrefixRootBlockCount: 5))
        #expect(
            MarkdownViewTestSupport.documentDebugDescription(result.document)
                == MarkdownViewTestSupport.fullParseDocumentDescription(markdown: new)
        )
    }

    @Test(
        "Reparses the last root block for an open code-fence append",
        .tags(.parsing, .incrementalParsing)
    )
    func reparsesTheLastRootBlockForOpenCodeFenceAppend() {
        let paragraphs = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
        let previous = paragraphs.joined(separator: "\n\n")
        let new = previous + "\n\n```swift\nlet value = 1"

        let previousResult = MarkdownViewTestSupport.makeParseResult(markdown: previous)
        let result = MarkdownDocumentParser.parse(
            MarkdownViewTestSupport.makeParseRequest(markdown: new),
            previousState: previousResult
        )

        #expect(result.parsingStrategy == .incremental(stablePrefixRootBlockCount: 5))
        #expect(
            MarkdownViewTestSupport.documentDebugDescription(result.document)
                == MarkdownViewTestSupport.fullParseDocumentDescription(markdown: new)
        )
    }

    @Test(
        "Reparses the last root block for a list continuation append",
        .tags(.parsing, .incrementalParsing, .lists)
    )
    func reparsesTheLastRootBlockForListContinuation() {
        let paragraphs = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
        let previous = paragraphs.joined(separator: "\n\n")
        let new = previous + "\n\n- item"

        let previousResult = MarkdownViewTestSupport.makeParseResult(markdown: previous)
        let result = MarkdownDocumentParser.parse(
            MarkdownViewTestSupport.makeParseRequest(markdown: new),
            previousState: previousResult
        )

        #expect(result.parsingStrategy == .incremental(stablePrefixRootBlockCount: 5))
        #expect(
            MarkdownViewTestSupport.documentDebugDescription(result.document)
                == MarkdownViewTestSupport.fullParseDocumentDescription(markdown: new)
        )
    }

    @Test(
        "Reparses the trailing table for the first appended body row",
        .tags(.parsing, .incrementalParsing)
    )
    func reparsesTheTrailingTableForTheFirstTableBodyRow() {
        let paragraphs = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
        let base = paragraphs.joined(separator: "\n\n")
        let previous = base + "\n\n| Name | Language |\n| --- | --- |"
        let new = previous + "\n| Swift | Native |"

        let previousResult = MarkdownViewTestSupport.makeParseResult(markdown: previous)
        let result = MarkdownDocumentParser.parse(
            MarkdownViewTestSupport.makeParseRequest(markdown: new),
            previousState: previousResult
        )

        #expect(result.parsingStrategy == .incremental(stablePrefixRootBlockCount: 6))
        #expect(
            MarkdownViewTestSupport.documentDebugDescription(result.document)
                == MarkdownViewTestSupport.fullParseDocumentDescription(markdown: new)
        )
    }

    @Test(
        "Falls back to a full parse for another trailing table body row",
        .tags(.parsing, .incrementalParsing)
    )
    func fallsBackForAnotherTrailingTableBodyRow() {
        let paragraphs = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
        let base = paragraphs.joined(separator: "\n\n")
        let previous = base + """

        | Name | Language |
        | --- | --- |
        | Swift | Native |
        """
        let new = previous + "\n| Rust | Systems |"

        let previousResult = MarkdownViewTestSupport.makeParseResult(markdown: previous)
        let result = MarkdownDocumentParser.parse(
            MarkdownViewTestSupport.makeParseRequest(markdown: new),
            previousState: previousResult
        )

        #expect(result.parsingStrategy == .full)
        #expect(
            MarkdownViewTestSupport.documentDebugDescription(result.document)
                == MarkdownViewTestSupport.fullParseDocumentDescription(markdown: new)
        )
    }

    @Test(
        "Reparses the full trailing table when a partial body row becomes valid",
        .tags(.parsing, .incrementalParsing)
    )
    func reparsesTheWholeTrailingTableWhenAPartialBodyRowBecomesAValidTableRow() {
        let previous = """
        ## Tables

        | Name | Language | Platform | Notes |
        |:-----|:--------:|---------:|------|
        | 
        """
        let new = previous + "Swift"

        let previousResult = MarkdownViewTestSupport.makeParseResult(markdown: previous)
        let result = MarkdownDocumentParser.parse(
            MarkdownViewTestSupport.makeParseRequest(markdown: new),
            previousState: previousResult
        )

        #expect(result.parsingStrategy == .incremental(stablePrefixRootBlockCount: 1))
        #expect(
            MarkdownViewTestSupport.documentDebugDescription(result.document)
                == MarkdownViewTestSupport.fullParseDocumentDescription(markdown: new)
        )
    }

    @Test(
        "Falls back to a full parse when an edit touches the stable prefix",
        .tags(.parsing, .incrementalParsing)
    )
    func fallsBackWhenEditTouchesStablePrefix() {
        let previous = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
            .joined(separator: "\n\n")
        let new = ["Alpha updated", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
            .joined(separator: "\n\n")

        let previousResult = MarkdownViewTestSupport.makeParseResult(markdown: previous)
        let result = MarkdownDocumentParser.parse(
            MarkdownViewTestSupport.makeParseRequest(markdown: new),
            previousState: previousResult
        )

        #expect(result.parsingStrategy == .full)
        #expect(
            MarkdownViewTestSupport.documentDebugDescription(result.document)
                == MarkdownViewTestSupport.fullParseDocumentDescription(markdown: new)
        )
    }

    @Test(
        "Falls back to a full parse for deletions",
        .tags(.parsing, .incrementalParsing)
    )
    func fallsBackForDeletion() {
        let previous = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
            .joined(separator: "\n\n")
        let new = ["Alpha", "Bravo", "Charlie", "Delta", "Echo"]
            .joined(separator: "\n\n")

        let previousResult = MarkdownViewTestSupport.makeParseResult(markdown: previous)
        let result = MarkdownDocumentParser.parse(
            MarkdownViewTestSupport.makeParseRequest(markdown: new),
            previousState: previousResult
        )

        #expect(result.parsingStrategy == .full)
        #expect(
            MarkdownViewTestSupport.documentDebugDescription(result.document)
                == MarkdownViewTestSupport.fullParseDocumentDescription(markdown: new)
        )
    }

    @Test(
        "Retains the previous parse result for an identical resend",
        .tags(.parsing, .incrementalParsing)
    )
    func usesIncrementalParsingForIdenticalResend() {
        let markdown = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot"]
            .joined(separator: "\n\n")

        let previousResult = MarkdownViewTestSupport.makeParseResult(markdown: markdown)
        let result = MarkdownDocumentParser.parse(
            MarkdownViewTestSupport.makeParseRequest(markdown: markdown),
            previousState: previousResult
        )

        #expect(result.parsingStrategy == .retained)
        #expect(
            MarkdownViewTestSupport.documentDebugDescription(result.document)
                == MarkdownViewTestSupport.fullParseDocumentDescription(markdown: markdown)
        )
    }

    #if ENABLE_MATH_RENDERING
    @Test(
        "Uses incremental parsing with inline math rendering enabled",
        .tags(.parsing, .incrementalParsing, .math)
    )
    func usesIncrementalParsingWhenMathRenderingIsEnabledForInlineMath() {
        let previous = "Inline math: $x$\n\nBravo"
        let new = previous + "\n\nTrailing math: $y$"

        let previousResult = MarkdownDocumentParser.parse(
            MarkdownViewTestSupport.makeParseRequest(
                markdown: previous,
                mathContext: MarkdownMathContext()
            )
        )
        let result = MarkdownDocumentParser.parse(
            MarkdownViewTestSupport.makeParseRequest(
                markdown: new,
                mathContext: MarkdownMathContext()
            ),
            previousState: previousResult
        )

        #expect(result.parsingStrategy == MarkdownParseResult.ParsingStrategy.incremental(stablePrefixRootBlockCount: 1))
        #expect(result.mathContext?.inlineMathStorage.count == 2)
        #expect(result.mathContext?.inlineMathStorage.values.contains("$x$") == true)
        #expect(result.mathContext?.inlineMathStorage.values.contains("$y$") == true)
        #expect(
            MarkdownViewTestSupport.documentDebugDescription(result.document)
                == MarkdownViewTestSupport.fullParseDocumentDescription(
                    markdown: new,
                    mathContext: MarkdownMathContext(),
                    requiresBlockDirectiveParsing: false
                )
        )
    }

    @Test(
        "Uses incremental parsing with display math rendering enabled",
        .tags(.parsing, .incrementalParsing, .math)
    )
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
            MarkdownViewTestSupport.makeParseRequest(
                markdown: previous,
                mathContext: MarkdownMathContext()
            )
        )
        let result = MarkdownDocumentParser.parse(
            MarkdownViewTestSupport.makeParseRequest(
                markdown: new,
                mathContext: MarkdownMathContext()
            ),
            previousState: previousResult
        )

        #expect(result.parsingStrategy == MarkdownParseResult.ParsingStrategy.incremental(stablePrefixRootBlockCount: 1))
        #expect(result.mathContext?.displayMathStorage.count == 2)
        #expect(result.mathContext?.displayMathStorage.values.contains("$$\nx\n$$") == true)
        #expect(result.mathContext?.displayMathStorage.values.contains("$$\ny\n$$") == true)
        #expect(
            MarkdownViewTestSupport.documentDebugDescription(result.document)
                == MarkdownViewTestSupport.fullParseDocumentDescription(
                    markdown: new,
                    mathContext: MarkdownMathContext(),
                    requiresBlockDirectiveParsing: false
                )
        )
    }

    @Test(
        "Preserves heading ranges when appending after stable display math",
        .tags(.parsing, .incrementalParsing, .math)
    )
    func preservesHeadingRangesWhenAppendingAfterStableDisplayMath() {
        let previous = """
        $$
        x
        $$

        ## Existing Section

        Body
        """
        let new = previous + """

        ### Appended Section

        Tail
        """

        let previousResult = MarkdownViewTestSupport.makeParseResult(
            markdown: previous,
            mathContext: MarkdownMathContext()
        )
        let incrementalResult = MarkdownDocumentParser.parse(
            MarkdownViewTestSupport.makeParseRequest(
                markdown: new,
                mathContext: MarkdownMathContext()
            ),
            previousState: previousResult
        )
        let fullResult = MarkdownViewTestSupport.makeParseResult(
            markdown: new,
            mathContext: MarkdownMathContext()
        )

        #expect(incrementalResult.parsingStrategy == .incremental(stablePrefixRootBlockCount: 2))
        #expect(
            MarkdownViewTestSupport.headingRanges(in: incrementalResult.document)
                == MarkdownViewTestSupport.headingRanges(in: fullResult.document)
        )
    }
    #endif

    @Test(
        "Preserves streamed Unicode tails",
        .tags(.parsing, .incrementalParsing, .streaming),
        arguments: StreamedUnicodeTailCase.allCases
    )
    func preservesStreamedUnicodeTails(testCase: StreamedUnicodeTailCase) {
        MarkdownViewTestSupport.assertStreamingMatchesFullParse(markdown: testCase.markdown)
    }

    @Test(
        "Preserves heading ranges when appending a tail parse",
        .tags(.parsing, .incrementalParsing)
    )
    func preservesHeadingRangesWhenAppendingATailParse() {
        let previous = """
        # Title

        Intro
        """
        let new = previous + """

        ## Appended Section

        Body
        """

        let previousResult = MarkdownViewTestSupport.makeParseResult(markdown: previous)
        let incrementalResult = MarkdownDocumentParser.parse(
            MarkdownViewTestSupport.makeParseRequest(markdown: new),
            previousState: previousResult
        )
        let fullResult = MarkdownViewTestSupport.makeParseResult(markdown: new)

        #expect(incrementalResult.parsingStrategy == .incremental(stablePrefixRootBlockCount: 1))
        #expect(
            MarkdownViewTestSupport.headingRanges(in: incrementalResult.document)
                == MarkdownViewTestSupport.headingRanges(in: fullResult.document)
        )
    }

    @MainActor
    @Test(
        "Parses from detached work without main-actor isolation",
        .tags(.parsing, .concurrency)
    )
    func parsesFromDetachedWorkWithoutMainActorIsolation() async {
        let request = MarkdownViewTestSupport.makeParseRequest(markdown: "# Title\n\nBody")

        let parseResult = await Task.detached(priority: .userInitiated) {
            MarkdownDocumentParser.parse(request)
        }.value

        #expect(parseResult.parsingStrategy == .full)
        #expect(
            MarkdownViewTestSupport.documentDebugDescription(parseResult.document)
                == MarkdownViewTestSupport.fullParseDocumentDescription(
                    markdown: "# Title\n\nBody"
                )
        )
    }

    enum StreamedUnicodeTailCase: CaseIterable {
        case emoji
        case cjk

        var markdown: String {
            switch self {
            case .emoji:
                """
                # Title

                Final line with emoji: 😀 🚀 ✨
                """
            case .cjk:
                """
                # 标题

                最后一行包含中文字符：叶子与结果
                """
            }
        }
    }
}
