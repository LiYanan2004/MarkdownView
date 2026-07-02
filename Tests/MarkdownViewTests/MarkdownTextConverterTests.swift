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
    @Test(
        "Converts basic Markdown nodes to plain text",
        .tags(.textConversion)
    )
    @MainActor
    func convertsBasicMarkdownNodesToPlainTextContent() {
        for fixture in PlainTextFixture.allCases {
            let textContent = MarkdownViewTestSupport.makeTextContent(markdown: fixture.markdown)
            let plainText = MarkdownViewTestSupport.plainText(in: textContent)

            #expect(
                plainText == fixture.expectedPlainText,
                "\(fixture.rawValue) converted to \(plainText.debugDescription)"
            )
        }
    }

    @Test(
        "Applies configured link attributes",
        .tags(.textConversion, .links)
    )
    @MainActor
    func appliesLinkAttributes() {
        let configuration = MarkdownRendererConfiguration()
            .with(\.preferredBaseURL, URL(string: "https://example.com/articles/"))
            .with(\.underlineLinks, true)
        let textContent = MarkdownViewTestSupport.makeTextContent(
            markdown: "[Read more](guide)",
            configuration: configuration
        )
        let attributedString = MarkdownViewTestSupport.attributedString(in: textContent)

        #expect(
            MarkdownViewTestSupport.link(in: attributedString, matching: "Read more")?.absoluteString
                == "https://example.com/articles/guide"
        )
        #expect(
            MarkdownViewTestSupport.underlineLineStyle(in: attributedString, matching: "Read more")
                == SwiftUI.Text.LineStyle.single
        )
    }

    @Test(
        "Embeds custom rendered links",
        .tags(.textConversion, .links)
    )
    @MainActor
    func embedsCustomRenderedLinks() {
        let textContent = MarkdownViewTestSupport.makeTextContent(
            markdown: "[Read more](custom://guide)",
            elementRenderers: [
                .link(MarkdownViewTestSupport.LinkRendererStub(), urlScheme: "custom")
            ]
        )

        #expect(MarkdownViewTestSupport.embeddedViewCount(in: textContent) == 1)
        #expect(MarkdownViewTestSupport.plainText(in: textContent) == "\u{FFFC}")
    }

    @Test(
        "Preserves inline presentation intents",
        .tags(.textConversion)
    )
    @MainActor
    func preservesInlinePresentationIntents() {
        for fixture in InlinePresentationIntentFixture.allCases {
            let textContent = MarkdownViewTestSupport.makeTextContent(markdown: fixture.markdown)
            let attributedString = MarkdownViewTestSupport.attributedString(in: textContent)
            let inlinePresentationIntent = MarkdownViewTestSupport.inlinePresentationIntent(
                in: attributedString,
                matching: fixture.plainText
            )

            #expect(
                inlinePresentationIntent?.contains(fixture.expectedIntent) == true,
                "\(fixture.rawValue) intent was \(String(describing: inlinePresentationIntent))"
            )
        }
    }

    @Test(
        "Embeds block attachments",
        .tags(.textConversion, .attachments)
    )
    @MainActor
    func embedsBlockAttachments() {
        for fixture in AttachmentFixture.allCases {
            let textContent = MarkdownViewTestSupport.makeTextContent(markdown: fixture.markdown)
            let embeddedViewCount = MarkdownViewTestSupport.embeddedViewCount(in: textContent)

            #expect(
                embeddedViewCount == fixture.expectedEmbeddedViewCount,
                "\(fixture.rawValue) embedded \(embeddedViewCount) view fragments"
            )
        }
    }

    #if ENABLE_MATH_RENDERING
    @Test(
        "Converts preprocessed inline math placeholders to embedded content",
        .tags(.textConversion, .math)
    )
    @MainActor
    func convertsPreprocessedInlineMathPlaceholdersToEmbeddedContent() {
        let preprocessingResult = MarkdownMathPreprocessor()
            .preprocessingResult(for: #"Value $x_y$ stays inline."#)

        let textContent = MarkdownViewTestSupport.makeTextContent(
            markdown: preprocessingResult.markdown,
            mathContext: preprocessingResult.context
        )
        let plainText = MarkdownViewTestSupport.plainText(in: textContent)

        #expect(MarkdownViewTestSupport.embeddedViewCount(in: textContent) == 1)
        #expect(!plainText.contains("markdownview-math(inline:"))
        #expect(plainText == "Value \u{FFFC} stays inline.")
    }

    @Test(
        "Converts preprocessed display math placeholders to embedded content",
        .tags(.textConversion, .math)
    )
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

        let textContent = MarkdownViewTestSupport.makeTextContent(
            markdown: preprocessingResult.markdown,
            mathContext: preprocessingResult.context,
            parseOptions: []
        )
        let plainText = MarkdownViewTestSupport.plainText(in: textContent)

        #expect(MarkdownViewTestSupport.embeddedViewCount(in: textContent) == 1)
        #expect(!plainText.contains("markdownview-math(display:"))
        #expect(!plainText.contains("$$"))
    }

    @Test(
        "Converts display math followed by inline text to embedded content",
        .tags(.textConversion, .math)
    )
    @MainActor
    func convertsDisplayMathFollowedByInlineTextToEmbeddedContent() {
        let preprocessingResult = MarkdownMathPreprocessor()
            .preprocessingResult(
                for: #"""
                1. **Sum of a Geometric Series**:
                    \[ S_n = a \frac{1-r^n}{1-r} \] (for \( r \neq 1 \))
                """#
            )

        let textContent = MarkdownViewTestSupport.makeTextContent(
            markdown: preprocessingResult.markdown,
            mathContext: preprocessingResult.context,
            parseOptions: []
        )
        let plainText = MarkdownViewTestSupport.plainText(in: textContent)

        #expect(MarkdownViewTestSupport.embeddedViewCount(in: textContent) == 2)
        #expect(!plainText.contains("markdownview-math(display:"))
        #expect(plainText.contains("(for "))
    }

    @Test(
        "Distinguishes math embedding identities by kind and occurrence",
        .tags(.textConversion, .math)
    )
    @MainActor
    func distinguishesMathEmbeddingIdentitiesByKindAndOccurrence() throws {
        let document = Document(parsing: "Math placeholders")
        let paragraph = try #require(Array(document.children).first as? Paragraph)
        let text = try #require(Array(paragraph.children).first as? Markdown.Text)

        let firstDisplayIdentifier = MarkdownTextInlineViewIdentifier(
            markup: text,
            role: .math(kind: .display, occurrence: 0)
        )
        let secondDisplayIdentifier = MarkdownTextInlineViewIdentifier(
            markup: text,
            role: .math(kind: .display, occurrence: 1)
        )
        let firstInlineIdentifier = MarkdownTextInlineViewIdentifier(
            markup: text,
            role: .math(kind: .inline, occurrence: 0)
        )

        #expect(firstDisplayIdentifier != secondDisplayIdentifier)
        #expect(firstDisplayIdentifier != firstInlineIdentifier)
    }
    #endif

    @Test(
        "Aligns list continuation paragraphs with the list item body",
        .tags(.textConversion, .lists)
    )
    @MainActor
    func alignsListContinuationParagraphsWithItemBody() {
        let textContent = MarkdownViewTestSupport.makeTextContent(
            markdown: """
            - First paragraph

              Continuation paragraph
            """
        )
        let attributedString = NSAttributedString(
            MarkdownViewTestSupport.attributedString(in: textContent)
        )
        let listItemParagraphStyle = MarkdownViewTestSupport.paragraphStyle(
            in: attributedString,
            matching: "First paragraph"
        )
        let continuationParagraphStyle = MarkdownViewTestSupport.paragraphStyle(
            in: attributedString,
            matching: "Continuation paragraph"
        )

        #expect(listItemParagraphStyle?.firstLineHeadIndent == 12)
        #expect(listItemParagraphStyle?.headIndent == 24)
        #expect(continuationParagraphStyle?.firstLineHeadIndent == 24)
        #expect(continuationParagraphStyle?.headIndent == 24)
    }

    @Test(
        "Applies the body font to list content",
        .tags(.textConversion, .lists),
        arguments: BodyFontFixture.allCases
    )
    @MainActor
    func appliesBodyFontToListContent(fixture: BodyFontFixture) {
        let bodyFont = PlatformFont.systemFont(ofSize: 30)
        let textContent = MarkdownViewTestSupport.makeTextContent(
            markdown: fixture.markdown,
            fonts: AnyMarkdownFontGroup(
                MarkdownViewTestSupport.FontGroupStub(bodyFont: bodyFont)
            )
        )
        let attributedString = NSAttributedString(
            MarkdownViewTestSupport.attributedString(in: textContent)
        )

        for substring in fixture.fontTrackedSubstrings {
            #expect(
                MarkdownViewTestSupport.font(in: attributedString, matching: substring)?.pointSize
                    == bodyFont.pointSize
            )
        }
    }

    @Test(
        "Applies list paragraph styling to the task-list checkbox",
        .tags(.textConversion, .lists)
    )
    @MainActor
    func appliesListParagraphStyleToTaskListCheckbox() {
        let textContent = MarkdownViewTestSupport.makeTextContent(markdown: "- [x] Done")
        let attributedString = NSAttributedString(
            MarkdownViewTestSupport.attributedString(in: textContent)
        )
        let checkboxParagraphStyle = MarkdownViewTestSupport.paragraphStyle(
            in: attributedString,
            matching: "\u{FFFC}"
        )

        #expect(checkboxParagraphStyle?.firstLineHeadIndent == 12)
        #expect(checkboxParagraphStyle?.headIndent == 24)
        #expect(checkboxParagraphStyle?.paragraphSpacing == 8)
    }

    @Test(
        "Applies paragraph spacing to code-block attachments",
        .tags(.textConversion, .attachments)
    )
    @MainActor
    func appliesParagraphSpacingToCodeBlockAttachment() {
        let textContent = MarkdownViewTestSupport.makeTextContent(
            markdown: """
            ```swift
            let value = 1
            ```
            """
        )
        let attributedString = NSAttributedString(
            MarkdownViewTestSupport.attributedString(in: textContent)
        )
        let codeBlockParagraphStyle = MarkdownViewTestSupport.paragraphStyle(
            in: attributedString,
            matching: "\u{FFFC}"
        )

        #expect(codeBlockParagraphStyle?.paragraphSpacing == 8)
    }

    @Test(
        "Preserves a list item that starts with a block attachment",
        .tags(.textConversion, .lists, .attachments)
    )
    @MainActor
    func preservesListItemThatStartsWithBlockAttachment() {
        let textContent = MarkdownViewTestSupport.makeTextContent(
            markdown: """
            -
              ```swift
              let value = 1
              ```
            """
        )

        #expect(MarkdownViewTestSupport.embeddedViewCount(in: textContent) == 1)
    }

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

    enum BodyFontFixture: CaseIterable {
        case listItem
        case taskListRow

        var markdown: String {
            switch self {
            case .listItem:
                "- First paragraph"
            case .taskListRow:
                "- [x] Completed task"
            }
        }

        var fontTrackedSubstrings: [String] {
            switch self {
            case .listItem:
                ["First paragraph"]
            case .taskListRow:
                ["\u{FFFC}", "Completed task"]
            }
        }
    }
}

#endif
