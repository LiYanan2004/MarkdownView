//
//  MarkdownQuoteAlertTests.swift
//  MarkdownView
//

import Foundation
import Markdown
import SwiftUI
import Testing

@testable import MarkdownView

@Suite("Markdown Quote Alert")
struct MarkdownQuoteAlertTests {
    @Test(
        "Uses the default title and preserves the first alert body paragraph",
        arguments: QuoteAlertBodyFixture.allCases
    )
    @MainActor
    func usesDefaultTitleAndPreservesFirstAlertBodyParagraph(
        fixture: QuoteAlertBodyFixture
    ) throws {
        let document = Document(parsing: fixture.markdown)
        let blockQuote = try #require(document.child(through: 0) as? BlockQuote)
        let children = Array(blockQuote.children)
        let firstParagraph = try #require(children.first as? Paragraph)
        let alert = try #require(
            MarkdownQuoteAlertType.detect(
                from: firstParagraph
            )
        )
        var bodyChildren: [any Markup] = []
        if let bodyParagraph = MarkdownViewRenderer.paragraphByStrippingCalloutPrefix(
            from: firstParagraph,
            prefix: "[!\(alert.type.rawValue)]"
        ) {
            bodyChildren.append(bodyParagraph)
        }
        bodyChildren.append(contentsOf: children.dropFirst())
        
        let renderedBody = bodyChildren
            .map(MarkdownViewRenderer.plainText(of:))
            .joined(separator: "\n")
        
        #expect(alert.title == fixture.expectedTitle)
        #expect(renderedBody.contains(fixture.expectedFirstBodyParagraph))
    }

    @Test("Preserves mixed inline content in one alert body paragraph")
    @MainActor
    func preservesMixedInlineContentInOneAlertBodyParagraph() throws {
        let document = Document(
            parsing: """
            > [!CAUTION]
            > A body containing **bold text**, *italic text*, `inline code`,
            > [a link](https://github.com), and ~~strikethrough text~~.
            """
        )
        let blockQuote = try #require(document.child(through: 0) as? BlockQuote)
        let paragraph = try #require(blockQuote.child(through: 0) as? Paragraph)

        let bodyParagraph = try #require(
            MarkdownViewRenderer.paragraphByStrippingCalloutPrefix(
                from: paragraph,
                prefix: "[!CAUTION]"
            )
        )

        #expect(bodyParagraph.childCount > 1)
        #expect(bodyParagraph.children.contains { $0 is Strong })
        #expect(bodyParagraph.children.contains { $0 is Emphasis })
        #expect(bodyParagraph.children.contains { $0 is InlineCode })
        #expect(bodyParagraph.children.contains { $0 is Markdown.Link })
        #expect(bodyParagraph.children.contains { $0 is Strikethrough })
        #expect(
            MarkdownViewRenderer.plainText(of: bodyParagraph)
                == "A body containing bold text, italic text, inline code,\n"
                    + "a link, and strikethrough text."
        )
    }

    @Test("An unquoted blank line ends an alert blockquote")
    func unquotedBlankLineEndsAlertBlockquote() {
        let document = Document(
            parsing: """
            > [!WARNING]

            > This is a separate blockquote.
            """
        )

        #expect(document.childCount == 2)
        #expect(document.children.allSatisfy { $0 is BlockQuote })
    }
    
    @Test(
        "Rejects marker-like text without a token boundary",
        arguments: QuoteAlertMarkerBoundaryFixture.allCases
    )
    func rejectsMarkerLikeTextWithoutTokenBoundary(
        fixture: QuoteAlertMarkerBoundaryFixture
    ) {
        #expect(MarkdownQuoteAlertType.detect(from: fixture.input) == nil)
    }
    
    #if canImport(RichText)
    @Test("Passes the quote alert setting to MarkdownText attachment rendering")
    @MainActor
    func passesQuoteAlertSettingToMarkdownTextAttachmentRendering() throws {
        let converter = MarkdownTextConverter(
            configuration: MarkdownRendererConfiguration(),
            mathContext: nil,
            elementRenderers: [],
            fonts: AnyMarkdownFontGroup(.automatic),
            quoteAlertEnabled: true
        )
        
        #expect(converter.makeAttachmentRenderer().quoteAlertEnabled)
    }
    #endif
    
    @Test(
        "Detects quote alert types from text",
        arguments: QuoteAlertDetectionFixture.allCases
    )
    func detectsQuoteAlertTypesFromText(fixture: QuoteAlertDetectionFixture) {
        let result = MarkdownQuoteAlertType.detect(from: fixture.input)
        if let expectedType = fixture.expectedType {
            #expect(result?.type == expectedType, "Expected \(expectedType) but got \(String(describing: result?.type))")
            #expect(result?.title == fixture.expectedTitle, "Expected title '\(fixture.expectedTitle)' but got '\(String(describing: result?.title))'")
        } else {
            #expect(result == nil, "Expected nil but got \(String(describing: result))")
        }
    }
    
    @Test(
        "Detects quote alert types case-insensitively",
        arguments: CaseInsensitiveFixture.allCases
    )
    func detectsQuoteAlertTypesCaseInsensitively(fixture: CaseInsensitiveFixture) {
        let result = MarkdownQuoteAlertType.detect(from: fixture.input)
        #expect(result?.type == fixture.expectedType, "Expected \(fixture.expectedType) but got \(String(describing: result?.type))")
    }
    
    @Test(
        "Parses quote alert blockquote as blockquote",
        arguments: QuoteAlertMarkdownFixture.allCases
    )
    func parsesQuoteAlertBlockquoteAsBlockquote(fixture: QuoteAlertMarkdownFixture) {
        let description = MarkdownViewTestSupport.fullParseDocumentDescription(
            markdown: fixture.markdown
        )
        #expect(description.contains("BlockQuote"), "Document should contain a BlockQuote")
    }
    
    @Test(
        "Regular blockquote without alert marker is not detected as alert"
    )
    func regularBlockquoteIsNotDetectedAsAlert() {
        let result = MarkdownQuoteAlertType.detect(from: "This is a regular quote")
        #expect(result == nil)
    }
    
    @Test("Rejects text after an alert marker on the same line")
    func alertWithCustomTitleIsRejected() {
        let result = MarkdownQuoteAlertType.detect(from: "[!NOTE] Custom Title Here")
        #expect(result == nil)
    }
    
    @Test("Allows whitespace around a standalone alert marker")
    func standaloneAlertMarkerWithExtraWhitespaceIsDetected() {
        let result = MarkdownQuoteAlertType.detect(from: "  [!WARNING]   ")
        #expect(result?.type == .warning)
        #expect(result?.title == "Warning")
    }

    @Test(
        "Only detects a plain alert marker on its own line",
        arguments: QuoteAlertSyntaxFixture.allCases
    )
    func onlyDetectsPlainStandaloneMarker(fixture: QuoteAlertSyntaxFixture) throws {
        let document = Document(parsing: fixture.markdown)
        let blockQuote = try #require(document.child(through: 0) as? BlockQuote)
        let paragraph = try #require(blockQuote.child(through: 0) as? Paragraph)

        let result = MarkdownQuoteAlertType.detect(from: paragraph)

        #expect((result != nil) == fixture.isAlert)
    }
}

// MARK: - Fixtures

extension MarkdownQuoteAlertTests {
    enum QuoteAlertSyntaxFixture: CaseIterable {
        case standaloneMarker
        case inlineCodeMarker
        case strongMarker
        case textAfterMarker

        var markdown: String {
            switch self {
                case .standaloneMarker:
                """
                > [!NOTE]
                > Alert body.
                """
                case .inlineCodeMarker:
                """
                > `[!NOTE]` is the token used to create a GitHub alert.
                > Place it on a dedicated line.
                """
                case .strongMarker:
                """
                > **[!WARNING]** is an example marker.
                > This paragraph documents the syntax.
                """
                case .textAfterMarker:
                """
                > [!NOTE] Migration status
                > Version 2 will be released on Monday.
                """
            }
        }

        var isAlert: Bool {
            self == .standaloneMarker
        }
    }

    enum QuoteAlertBodyFixture: CaseIterable {
        case singleParagraph
        case multipleParagraphs
        
        var markdown: String {
            switch self {
                case .singleParagraph:
                """
                > [!NOTE]
                > First paragraph.
                """
                case .multipleParagraphs:
                """
                > [!NOTE]
                > First paragraph.
                >
                > Second paragraph.
                """
            }
        }
        
        var expectedFirstBodyParagraph: String {
            "First paragraph."
        }
        
        var expectedTitle: String {
            "Note"
        }
    }
    
    enum QuoteAlertMarkerBoundaryFixture: CaseIterable {
        case noteSuffix
        case warningSuffix
        
        var input: String {
            switch self {
                case .noteSuffix: "[!NOTE]worthy text"
                case .warningSuffix: "[!WARNING]details"
            }
        }
    }
    
    enum QuoteAlertDetectionFixture: CaseIterable {
        case note
        case tip
        case important
        case warning
        case caution
        case unknownPrefix
        case invalidFormat
        case emptyString
        
        var input: String {
            switch self {
                case .note: "[!NOTE]"
                case .tip: "[!TIP]"
                case .important: "[!IMPORTANT]"
                case .warning: "[!WARNING]"
                case .caution: "[!CAUTION]"
                case .unknownPrefix: "[!UNKNOWN]"
                case .invalidFormat: "Just some text"
                case .emptyString: ""
            }
        }
        
        var expectedType: MarkdownQuoteAlertType? {
            switch self {
                case .note: .note
                case .tip: .tip
                case .important: .important
                case .warning: .warning
                case .caution: .caution
                case .unknownPrefix: nil
                case .invalidFormat: nil
                case .emptyString: nil
            }
        }
        
        var expectedTitle: String {
            switch self {
                case .note: "Note"
                case .tip: "Tip"
                case .important: "Important"
                case .warning: "Warning"
                case .caution: "Caution"
                case .unknownPrefix: ""
                case .invalidFormat: ""
                case .emptyString: ""
            }
        }
    }
    
    enum CaseInsensitiveFixture: CaseIterable {
        case noteLower
        case warningMixed
        case cautionLower
        case tipMixed
        case importantLower
        
        var input: String {
            switch self {
                case .noteLower: "[!note]"
                case .warningMixed: "[!Warning]"
                case .cautionLower: "[!caution]"
                case .tipMixed: "[!Tip]"
                case .importantLower: "[!important]"
            }
        }
        
        var expectedType: MarkdownQuoteAlertType {
            switch self {
                case .noteLower: .note
                case .warningMixed: .warning
                case .cautionLower: .caution
                case .tipMixed: .tip
                case .importantLower: .important
            }
        }
    }
    
    enum QuoteAlertMarkdownFixture: CaseIterable {
        case noteAllCaps
        case tipAllCaps
        case importantAllCaps
        case warningMixed
        case cautionMixed
        
        var markdown: String {
            switch self {
                case .noteAllCaps:
                """
                > [!NOTE]
                >
                > This is a note.
                """
                case .tipAllCaps:
                """
                > [!TIP]
                >
                > This is a tip.
                """
                case .importantAllCaps:
                """
                > [!IMPORTANT]
                >
                > This is important.
                """
                case .warningMixed:
                """
                > [!Warning]
                >
                > Warning body content.
                """
                case .cautionMixed:
                """
                > [!Caution]
                >
                > Caution body content.
                """
            }
        }
    }
}
