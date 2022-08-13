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

struct PaddingLine: View {
    var count: Int = 1
    var body: some View {
        SwiftUI.Text([String](repeating: "\n", count: count - 1).joined())
            .frame(maxWidth: .infinity)
    }
}

struct NewLine: View {
    var body: some View {
        PaddingLine()
            .frame(height: 0) // Break the Text into two lines while maintaining the line spacing
    }
}
