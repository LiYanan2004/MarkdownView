import MarkdownView
import SwiftUI

#Preview(traits: .markdownViewExample) {
    let markdownText = """
    # Interaction Example

    This preview enables text selection and link interaction.

    Visit [Swift.org](https://swift.org) for Swift language updates.

    Inline math can also be enabled: $E = mc^2$.
    """

    MarkdownView(markdownText)
        .markdownTextSelection(.enabled)
        .markdownMathRenderingEnabled()
}
