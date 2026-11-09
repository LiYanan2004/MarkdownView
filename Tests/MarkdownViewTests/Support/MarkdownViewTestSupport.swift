import Foundation
import Markdown
#if canImport(RichText)
import RichText
#endif
import SwiftUI
import Testing

@testable import MarkdownView

enum MarkdownViewTestSupport {
    static func makeParseRequest(
        markdown: String,
        mathContext: MarkdownMathContext? = nil,
        requiresBlockDirectiveParsing: Bool = false
    ) -> MarkdownParseRequest {
        let elementRenderers: [MarkdownElementRendererRegistration]
        if requiresBlockDirectiveParsing {
            elementRenderers = [
                .blockDirective(BlockDirectiveRendererStub(), name: "Note")
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

    static func makeParseResult(
        markdown: String,
        mathContext: MarkdownMathContext? = nil,
        requiresBlockDirectiveParsing: Bool = false
    ) -> MarkdownParseResult {
        MarkdownDocumentParser.parse(
            makeParseRequest(
                markdown: markdown,
                mathContext: mathContext,
                requiresBlockDirectiveParsing: requiresBlockDirectiveParsing
            )
        )
    }

    static func fullParseDocumentDescription(
        markdown: String,
        mathContext: MarkdownMathContext? = nil,
        requiresBlockDirectiveParsing: Bool = false
    ) -> String {
        documentDebugDescription(
            makeParseResult(
                markdown: markdown,
                mathContext: mathContext,
                requiresBlockDirectiveParsing: requiresBlockDirectiveParsing
            ).document
        )
    }

    static func documentDebugDescription(_ document: Markdown.Document) -> String {
        document.debugDescription()
    }

    static func headingRanges(in document: Markdown.Document) -> [SourceRange?] {
        var headingRangeCollector = HeadingRangeCollector()
        headingRangeCollector.visit(document)
        return headingRangeCollector.headingRanges
    }

    static func assertStreamingMatchesFullParse(
        markdown: String,
        mathContext: MarkdownMathContext? = nil,
        requiresBlockDirectiveParsing: Bool = false
    ) {
        var streamedMarkdown = ""
        var previousParseResult: MarkdownParseResult?

        for character in markdown {
            streamedMarkdown.append(character)

            let parseResult = MarkdownDocumentParser.parse(
                makeParseRequest(
                    markdown: streamedMarkdown,
                    mathContext: mathContext,
                    requiresBlockDirectiveParsing: requiresBlockDirectiveParsing
                ),
                previousState: previousParseResult
            )

            #expect(
                documentDebugDescription(parseResult.document) == fullParseDocumentDescription(
                    markdown: streamedMarkdown,
                    mathContext: mathContext,
                    requiresBlockDirectiveParsing: requiresBlockDirectiveParsing
                )
            )

            previousParseResult = parseResult
        }
    }

    @MainActor
    static func waitUntil(
        timeout: Duration = .seconds(1),
        pollInterval: Duration = .milliseconds(10),
        condition: () -> Bool
    ) async throws {
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: timeout)

        while condition() == false {
            if clock.now >= deadline {
                break
            }

            try await Task.sleep(for: pollInterval)
        }

        #expect(condition(), "Timed out waiting for condition.")
    }

    static func extractedMathRepresentations(in markdown: String) -> [String] {
        MathParser(text: markdown).mathRepresentations.map { mathRepresentation in
            String(markdown[mathRepresentation.range])
        }
    }

    static func makeMathPreprocessingResult(
        for markdown: String,
        requiresBlockDirectiveParsing: Bool = false
    ) -> MarkdownMathPreprocessor.Result {
        MarkdownMathPreprocessor().preprocessingResult(
            for: markdown,
            requiresBlockDirectiveParsing: requiresBlockDirectiveParsing
        )
    }

    struct BlockDirectiveRendererStub: MarkdownBlockDirectiveRenderer {
        func makeBody(configuration: MarkdownBlockDirectiveRendererConfiguration) -> some View {
            EmptyView()
        }
    }

    private struct HeadingRangeCollector: MarkupWalker {
        private(set) var headingRanges: [SourceRange?] = []

        mutating func visitHeading(_ heading: Markdown.Heading) {
            headingRanges.append(heading.range)
            descendInto(heading)
        }
    }

    #if canImport(RichText)
    @MainActor
    static func makeTextContent(
        markdown: String,
        configuration: MarkdownRendererConfiguration = MarkdownRendererConfiguration(),
        mathContext: MarkdownMathContext? = nil,
        elementRenderers: [MarkdownElementRendererRegistration] = [],
        fonts: AnyMarkdownFontGroup = AnyMarkdownFontGroup(.automatic),
        parseOptions: ParseOptions = []
    ) -> TextContent {
        let converter = MarkdownTextConverter(
            configuration: configuration,
            mathContext: mathContext,
            elementRenderers: elementRenderers,
            fonts: fonts
        )

        return converter.makeTextContent(
            for: Document(parsing: markdown, options: parseOptions)
        )
    }

    @MainActor
    static func attributedString(in textContent: TextContent) -> AttributedString {
        textContent.fragments.reduce(into: AttributedString()) { attributedString, fragment in
            attributedString += fragment.asAttributedString()
        }
    }

    @MainActor
    static func plainText(in textContent: TextContent) -> String {
        String(attributedString(in: textContent).characters)
    }

    @MainActor
    static func embeddedViewCount(in textContent: TextContent) -> Int {
        String(attributedString(in: textContent).characters)
            .filter { $0 == "\u{FFFC}" }
            .count
    }

    static func inlinePresentationIntent(
        in attributedString: AttributedString,
        matching substring: String
    ) -> InlinePresentationIntent? {
        firstRun(in: attributedString, matching: substring)?.inlinePresentationIntent
    }

    static func link(
        in attributedString: AttributedString,
        matching substring: String
    ) -> URL? {
        firstRun(in: attributedString, matching: substring)?.link
    }

    static func underlineLineStyle(
        in attributedString: AttributedString,
        matching substring: String
    ) -> SwiftUI.Text.LineStyle? {
        firstRun(in: attributedString, matching: substring)?.underlineStyle
    }

    static func font(
        in attributedString: NSAttributedString,
        matching substring: String
    ) -> PlatformFont? {
        let range = (attributedString.string as NSString).range(of: substring)
        guard range.location != NSNotFound else {
            return nil
        }

        return attributedString.attribute(
            .font,
            at: range.location,
            effectiveRange: nil
        ) as? PlatformFont
    }

    static func paragraphStyle(
        in attributedString: NSAttributedString,
        matching substring: String
    ) -> NSParagraphStyle? {
        let range = (attributedString.string as NSString).range(of: substring)
        guard range.location != NSNotFound else {
            return nil
        }

        return attributedString.attribute(
            .paragraphStyle,
            at: range.location,
            effectiveRange: nil
        ) as? NSParagraphStyle
    }

    struct FontGroupStub: MarkdownFontGroup {
        var bodyFont: PlatformFont
        var blockQuoteFont = PlatformFont.systemFont(ofSize: 13)
        var tableHeaderFont = PlatformFont.systemFont(ofSize: 13)
        var tableBodyFont = PlatformFont.systemFont(ofSize: 13)

        var body: any CustomCTFontConvertible {
            bodyFont
        }

        var blockQuote: any CustomCTFontConvertible {
            blockQuoteFont
        }

        var tableHeader: any CustomCTFontConvertible {
            tableHeaderFont
        }

        var tableBody: any CustomCTFontConvertible {
            tableBodyFont
        }
    }

    struct LinkRendererStub: MarkdownLinkRenderer {
        func makeBody(configuration: MarkdownLinkRendererConfiguration) -> some View {
            configuration.label
        }
    }

    private static func firstRun(
        in attributedString: AttributedString,
        matching substring: String
    ) -> AttributedString.Runs.Run? {
        guard let range = attributedString.range(of: substring) else {
            return nil
        }

        return attributedString.runs.first { run in
            run.range.overlaps(range)
        }
    }
    #endif
}
