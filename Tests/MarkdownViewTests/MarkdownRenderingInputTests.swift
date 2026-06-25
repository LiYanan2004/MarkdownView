import Markdown
import SwiftUI
import Testing

@testable import MarkdownView

@Suite("Markdown Rendering Input")
struct MarkdownRenderingInputTests {
    @Test("Math rendering alone does not enable block directive parsing")
    func mathRenderingAloneDoesNotEnableBlockDirectiveParsing() {
        let configuration = MarkdownRendererConfiguration()
            .with(\.math.shouldRender, true)
        let renderingInput = MarkdownRenderingInput(
            source: .rawText("@Note()"),
            configuration: configuration,
            elementRenderers: []
        )

        #expect(Array(renderingInput.document.children).first is Markdown.Paragraph)
    }

    @Test("Custom block directive renderers enable block directive parsing")
    func customBlockDirectiveRenderersEnableBlockDirectiveParsing() {
        let renderingInput = MarkdownRenderingInput(
            source: .rawText("@Note()"),
            configuration: .init(),
            elementRenderers: [
                .blockDirective(TestBlockDirectiveRenderer(), name: "Note")
            ]
        )

        #expect(Array(renderingInput.document.children).first is Markdown.BlockDirective)
    }
}

private struct TestBlockDirectiveRenderer: MarkdownBlockDirectiveRenderer {
    func makeBody(configuration: MarkdownBlockDirectiveRendererConfiguration) -> some View {
        EmptyView()
    }
}
