import Markdown
import SwiftUI
import Testing

@testable import MarkdownView

@Suite("Markdown Rendering Input")
struct MarkdownRenderingInputTests {
    @Test("Math rendering alone does not enable block directive parsing")
    func mathRenderingAloneDoesNotEnableBlockDirectiveParsing() {
        let renderingInput = MarkdownRenderingInput(
            sourceText: "@Note()",
            mathContext: MarkdownMathContext(),
            elementRenderers: []
        )
        let renderingOutput = MarkdownDocumentParser.parse(renderingInput)

        #expect(renderingInput.parsingOptions.contains(.parsesBlockDirectives) == false)
        #expect(Array(renderingOutput.document.children).first is Markdown.Paragraph)
    }

    @Test("Custom block directive renderers enable block directive parsing")
    func customBlockDirectiveRenderersEnableBlockDirectiveParsing() {
        let renderingInput = MarkdownRenderingInput(
            sourceText: "@Note()",
            mathContext: nil,
            elementRenderers: [
                .blockDirective(TestBlockDirectiveRenderer(), name: "Note")
            ]
        )
        let renderingOutput = MarkdownDocumentParser.parse(renderingInput)

        #expect(renderingInput.parsingOptions.contains(.parsesBlockDirectives))
        #expect(Array(renderingOutput.document.children).first is Markdown.BlockDirective)
    }
}

private struct TestBlockDirectiveRenderer: MarkdownBlockDirectiveRenderer {
    func makeBody(configuration: MarkdownBlockDirectiveRendererConfiguration) -> some View {
        EmptyView()
    }
}
