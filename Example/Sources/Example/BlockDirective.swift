import MarkdownView
import SwiftUI

private struct NoteBlockDirectiveRenderer: BlockDirectiveRenderer {
    func makeBody(configuration: Configuration) -> some View {
        Text(configuration.wrappedString)
            .padding(20)
            .background(
                Color.yellow.opacity(0.25),
                in: RoundedRectangle(cornerRadius: 12)
            )
    }
}

private extension BlockDirectiveRenderer where Self == NoteBlockDirectiveRenderer {
    static var previewNoteRenderer: NoteBlockDirectiveRenderer { .init() }
}

#Preview(traits: .markdownViewExample) {
    let markdownText = #"""
    @note {
    This is a note directive block. Use custom block directive renderers to style directive content.
    }
    """#

    MarkdownView(markdownText)
        .blockDirectiveRenderer(.previewNoteRenderer, for: "note")
        .frame(width: 500)
}
