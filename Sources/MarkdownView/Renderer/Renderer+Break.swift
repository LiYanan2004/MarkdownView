import SwiftUI
import Markdown

extension Renderer {
    func visitSoftBreak(_ softBreak: SoftBreak) -> AnyView {
        AnyView(SwiftUI.Text(" "))
    }
    
    func visitThematicBreak(_ thematicBreak: ThematicBreak) -> AnyView {
        AnyView(Divider())
    }

    func visitLineBreak(_ lineBreak: LineBreak) -> AnyView {
        AnyView(NewLine())
    }
}

/// A helper view that can render next text in a new line.
struct NewLine: View {
    var body: some View {
        SwiftUI.Text("\n")
            .frame(maxWidth: .infinity)
            .frame(height: 0) // Break the Text into two lines while maintaining the line spacing
    }
}
