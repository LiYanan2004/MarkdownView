import Markdown
import Testing

@testable import MarkdownView

@Suite("Block Directive Content")
struct BlockDirectiveContentTests {
    @Test("Preserves wrapped Markdown when parsed again", arguments: ContentFixture.allCases)
    func preservesWrappedMarkdown(fixture: ContentFixture) throws {
        let document = Document(
            parsing: "@callout(type: \"tip\") {\n\(fixture.markdown)\n}",
            options: [.parseBlockDirectives]
        )
        let directive = try #require(document.child(at: 0) as? BlockDirective)
        let expectedDocument = Document(parsing: fixture.markdown, options: [.parseBlockDirectives])
        let wrappedMarkdown = directive.wrappedMarkdown
        let reparsedDocument = Document(parsing: wrappedMarkdown, options: [.parseBlockDirectives])

        #expect(wrappedMarkdown == expectedDocument.format())
        #expect(reparsedDocument.hasSameStructure(as: expectedDocument))
        #expect(directive.parent is Document)
    }

    enum ContentFixture: CaseIterable {
        case paragraphsAndList, codeBlock, nestedDirective, blockQuote, empty

        var markdown: String {
            switch self {
            case .paragraphsAndList:
                """
                MarkdownText and MarkdownView can embed a custom SwiftUI view from a block directive.

                - Arguments are available to the renderer.
                - The wrapped markdown remains visible as preview content.
                """
            case .codeBlock:
                """
                Before the code.

                ```swift
                let value = 1
                    print(value)
                ```

                After the code.
                """
            case .nestedDirective:
                """
                @callout(type: "warning") {
                Nested **content**.
                }
                """
            case .blockQuote:
                """
                > Quoted content.
                >
                > - Nested item
                """
            case .empty:
                ""
            }
        }
    }
}
