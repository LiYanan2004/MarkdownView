//
//  MarkdownTextConverterTests.swift
//  MarkdownView
//
//  Created by Codex on 2026/6/17.
//

#if canImport(RichText)

import Foundation
import Markdown
import RichText
import SwiftUI
import Testing

@testable import MarkdownView

@Suite("Markdown Text Converter")
struct MarkdownTextConverterTests {
    @Test("Converts basic markdown nodes to plain text content")
    @MainActor
    func convertsBasicMarkdownNodesToPlainTextContent() {
        for fixture in PlainTextFixture.allCases {
            let textContent = Self.makeTextContent(markdown: fixture.markdown)

            #expect(
                textContent.plainText == fixture.expectedPlainText,
                "\(fixture.rawValue) converted to \(textContent.plainText.debugDescription)"
            )
        }
    }

    @Test("Applies link attributes")
    @MainActor
    func appliesLinkAttributes() {
        let configuration = MarkdownRendererConfiguration()
            .with(\.preferredBaseURL, URL(string: "https://example.com/articles/"))
            .with(\.underlineLinks, true)
        let textContent = Self.makeTextContent(
            markdown: "[Read more](guide)",
            configuration: configuration
        )
        let attributedString = textContent.attributedStringForTesting

        #expect(attributedString.link(for: "Read more")?.absoluteString == "https://example.com/articles/guide")
        #expect(attributedString.underlineLineStyle(for: "Read more") == SwiftUI.Text.LineStyle.single)
    }

    @Test("Embeds custom rendered links")
    @MainActor
    func embedsCustomRenderedLinks() {
        let textContent = Self.makeTextContent(
            markdown: "[Read more](custom://guide)",
            elementRenderers: [
                .link(TestMarkdownLinkRenderer(), urlScheme: "custom")
            ]
        )

        #expect(textContent.embeddedViewCount == 1)
        #expect(textContent.plainText == "\u{FFFC}")
    }

    @Test("Preserves inline presentation intents")
    @MainActor
    func preservesInlinePresentationIntents() {
        for fixture in InlinePresentationIntentFixture.allCases {
            let textContent = Self.makeTextContent(markdown: fixture.markdown)
            let inlinePresentationIntent = textContent
                .attributedStringForTesting
                .inlinePresentationIntent(for: fixture.plainText)

            #expect(
                inlinePresentationIntent?.contains(fixture.expectedIntent) == true,
                "\(fixture.rawValue) intent was \(String(describing: inlinePresentationIntent))"
            )
        }
    }

    @Test("Embeds block attachments")
    @MainActor
    func embedsBlockAttachments() {
        for fixture in AttachmentFixture.allCases {
            let textContent = Self.makeTextContent(markdown: fixture.markdown)

            #expect(
                textContent.embeddedViewCount == fixture.expectedEmbeddedViewCount,
                "\(fixture.rawValue) embedded \(textContent.embeddedViewCount) view fragments"
            )
        }
    }

    #if ENABLE_MATH_RENDERING
    @Test("Converts preprocessed inline math placeholders to embedded content")
    @MainActor
    func convertsPreprocessedInlineMathPlaceholdersToEmbeddedContent() {
        let preprocessingResult = MarkdownMathPreprocessor()
            .preprocessingResult(for: #"Value $x_y$ stays inline."#)

        let textContent = Self.makeTextContent(
            markdown: preprocessingResult.markdown,
            mathContext: preprocessingResult.context
        )

        #expect(textContent.embeddedViewCount == 1)
        #expect(!textContent.plainText.contains("markdownview-math(inline:"))
        #expect(textContent.plainText == "Value \u{FFFC} stays inline.")
    }
    @Test("Converts preprocessed display math placeholders to embedded content")
    @MainActor
    func convertsPreprocessedDisplayMathPlaceholdersToEmbeddedContent() {
        let preprocessingResult = MarkdownMathPreprocessor()
            .preprocessingResult(
                for: #"""
                Display math:

                $$
                \int_0^1 x^2\,dx = \frac{1}{3}
                $$
                """#
            )

        let textContent = Self.makeTextContent(
            markdown: preprocessingResult.markdown,
            mathContext: preprocessingResult.context,
            parseOptions: []
        )

        #expect(textContent.embeddedViewCount == 1)
        #expect(!textContent.plainText.contains("markdownview-math(display:"))
        #expect(!textContent.plainText.contains("$$"))
    }
    #endif

    @Test("Aligns list continuation paragraphs with item body")
    @MainActor
    func alignsListContinuationParagraphsWithItemBody() {
        let textContent = Self.makeTextContent(
            markdown: """
            - First paragraph

              Continuation paragraph
            """
        )
        let attributedString = NSAttributedString(textContent.attributedStringForTesting)
        let listItemParagraphStyle = attributedString.paragraphStyle(for: "First paragraph")
        let continuationParagraphStyle = attributedString.paragraphStyle(for: "Continuation paragraph")

        #expect(listItemParagraphStyle?.firstLineHeadIndent == 12)
        #expect(listItemParagraphStyle?.headIndent == 24)
        #expect(continuationParagraphStyle?.firstLineHeadIndent == 24)
        #expect(continuationParagraphStyle?.headIndent == 24)
    }

    @Test("Applies body font to list item first paragraph")
    @MainActor
    func appliesBodyFontToListItemFirstParagraph() {
        let bodyFont = PlatformFont.systemFont(ofSize: 30)
        let textContent = Self.makeTextContent(
            markdown: "- First paragraph",
            fonts: AnyMarkdownFontGroup(TestMarkdownFontGroup(bodyFont: bodyFont))
        )
        let attributedString = NSAttributedString(textContent.attributedStringForTesting)

        #expect(attributedString.font(for: "First paragraph")?.pointSize == bodyFont.pointSize)
    }

    @Test("Applies body font to task list row")
    @MainActor
    func appliesBodyFontToTaskListRow() {
        let bodyFont = PlatformFont.systemFont(ofSize: 30)
        let textContent = Self.makeTextContent(
            markdown: "- [x] Completed task",
            fonts: AnyMarkdownFontGroup(TestMarkdownFontGroup(bodyFont: bodyFont))
        )
        let attributedString = NSAttributedString(textContent.attributedStringForTesting)

        #expect(attributedString.font(for: "\u{FFFC}")?.pointSize == bodyFont.pointSize)
        #expect(attributedString.font(for: "Completed task")?.pointSize == bodyFont.pointSize)
    }

    @Test("Applies list paragraph style to task list checkbox")
    @MainActor
    func appliesListParagraphStyleToTaskListCheckbox() {
        let textContent = Self.makeTextContent(markdown: "- [x] Done")
        let attributedString = NSAttributedString(textContent.attributedStringForTesting)
        let checkboxParagraphStyle = attributedString.paragraphStyle(for: "\u{FFFC}")

        #expect(checkboxParagraphStyle?.firstLineHeadIndent == 12)
        #expect(checkboxParagraphStyle?.headIndent == 24)
        #expect(checkboxParagraphStyle?.paragraphSpacing == 8)
    }

    @Test("Applies paragraph spacing to code block attachment")
    @MainActor
    func appliesParagraphSpacingToCodeBlockAttachment() {
        let textContent = Self.makeTextContent(
            markdown: """
            ```swift
            let value = 1
            ```
            """
        )
        let attributedString = NSAttributedString(textContent.attributedStringForTesting)
        let codeBlockParagraphStyle = attributedString.paragraphStyle(for: "\u{FFFC}")

        #expect(codeBlockParagraphStyle?.paragraphSpacing == 8)
    }

    @Test("Preserves list item that starts with block attachment")
    @MainActor
    func preservesListItemThatStartsWithBlockAttachment() {
        let textContent = Self.makeTextContent(
            markdown: """
            -
              ```swift
              let value = 1
              ```
            """
        )

        #expect(textContent.embeddedViewCount == 1)
    }

}

private extension MarkdownTextConverterTests {
    enum PlainTextFixture: String, CaseIterable {
        case paragraph
        case paragraphs
        case heading
        case softBreak
        case lineBreak
        case inlineCode
        case unorderedList
        case orderedList
        case taskList

        var markdown: String {
            switch self {
            case .paragraph:
                "Hello **World**."
            case .paragraphs:
                """
                First paragraph.

                Second paragraph.
                """
            case .heading:
                "# Title"
            case .softBreak:
                """
                First
                Second
                """
            case .lineBreak:
                """
                First  
                Second
                """
            case .inlineCode:
                "`let value = 1`"
            case .unorderedList:
                """
                - One
                - Two
                """
            case .orderedList:
                """
                1. One
                2. Two
                """
            case .taskList:
                """
                - [x] Done
                - [ ] Todo
                """
            }
        }

        var expectedPlainText: String {
            switch self {
            case .paragraph:
                "Hello World."
            case .paragraphs:
                "First paragraph.\nSecond paragraph."
            case .heading:
                "Title"
            case .softBreak:
                "First Second"
            case .lineBreak:
                "First\nSecond"
            case .inlineCode:
                "let value = 1"
            case .unorderedList:
                "• One\n• Two"
            case .orderedList:
                "1. One\n2. Two"
            case .taskList:
                "\u{FFFC} Done\n\u{FFFC} Todo"
            }
        }
    }

    enum AttachmentFixture: String, CaseIterable {
        case thematicBreak
        case blockQuote
        case codeBlock
        case table
        case image

        var markdown: String {
            switch self {
            case .thematicBreak:
                "---"
            case .blockQuote:
                "> Quote"
            case .codeBlock:
                """
                ```swift
                let value = 1
                ```
                """
            case .table:
                """
                | Name | Value |
                | ---- | ----- |
                | One  | 1     |
                """
            case .image:
                "![Logo](https://example.com/logo.png)"
            }
        }

        var expectedEmbeddedViewCount: Int {
            1
        }
    }

    enum InlinePresentationIntentFixture: String, CaseIterable {
        case strong
        case emphasis
        case strikethrough

        var markdown: String {
            switch self {
            case .strong:
                "**Strong**"
            case .emphasis:
                "*Emphasis*"
            case .strikethrough:
                "~~Strike~~"
            }
        }

        var expectedIntent: InlinePresentationIntent {
            switch self {
            case .strong:
                .stronglyEmphasized
            case .emphasis:
                .emphasized
            case .strikethrough:
                .strikethrough
            }
        }

        var plainText: String {
            switch self {
            case .strong:
                "Strong"
            case .emphasis:
                "Emphasis"
            case .strikethrough:
                "Strike"
            }
        }
    }

    @MainActor static func makeTextContent(
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
        return converter.makeTextContent(for: Document(parsing: markdown, options: parseOptions))
    }
}

private struct TestMarkdownFontGroup: MarkdownFontGroup {
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

private struct TestMarkdownLinkRenderer: MarkdownLinkRenderer {
    func makeBody(configuration: MarkdownLinkRendererConfiguration) -> some View {
        configuration.label
    }
}

private extension AttributedString {
    func inlinePresentationIntent(
        for substring: String
    ) -> InlinePresentationIntent? {
        guard let range = range(of: substring) else {
            return nil
        }

        return firstRun(overlapping: range)?.inlinePresentationIntent
    }

    func link(for substring: String) -> URL? {
        guard let range = range(of: substring) else {
            return nil
        }

        return firstRun(overlapping: range)?.link
    }

    func underlineLineStyle(
        for substring: String
    ) -> SwiftUI.Text.LineStyle? {
        guard let range = range(of: substring) else {
            return nil
        }

        return firstRun(overlapping: range)?.underlineStyle
    }

    func firstRun(
        overlapping range: Range<AttributedString.Index>
    ) -> AttributedString.Runs.Run? {
        runs.first { run in
            run.range.overlaps(range)
        }
    }
}

private extension NSAttributedString {
    func font(for substring: String) -> PlatformFont? {
        let range = (string as NSString).range(of: substring)
        guard range.location != NSNotFound else {
            return nil
        }

        return attribute(
            .font,
            at: range.location,
            effectiveRange: nil
        ) as? PlatformFont
    }

    func paragraphStyle(for substring: String) -> NSParagraphStyle? {
        let range = (string as NSString).range(of: substring)
        guard range.location != NSNotFound else {
            return nil
        }

        return attribute(
            .paragraphStyle,
            at: range.location,
            effectiveRange: nil
        ) as? NSParagraphStyle
    }
}

private extension TextContent {
    @MainActor
    var plainText: String {
        String(attributedStringForTesting.characters)
    }

    @MainActor
    var embeddedViewCount: Int {
        String(attributedStringForTesting.characters)
            .filter { $0 == "\u{FFFC}" }
            .count
    }

    @MainActor
    var attributedStringForTesting: AttributedString {
        fragments.reduce(into: AttributedString()) { attributedString, fragment in
            attributedString += fragment.asAttributedString()
        }
    }
}

#endif
