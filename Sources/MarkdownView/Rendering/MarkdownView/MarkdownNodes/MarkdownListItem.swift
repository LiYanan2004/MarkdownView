import SwiftUI
import Markdown

struct MarkdownListItem: View {
    var listItem: ListItem
    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.markdownMathContext) private var mathContext
    @Environment(\.markdownElementRenderers) private var elementRenderers
    
    var body: some View {
        VStack(alignment: .leading, spacing: configuration.componentSpacing) {
            ForEach(Array(listItem.children.enumerated()), id: \.offset) { (_, child) in
                MarkdownViewRenderer(
                    configuration: configuration,
                    mathContext: mathContext,
                    elementRenderers: elementRenderers
                )
                .makeBody(for: child)
            }
        }
    }
}
