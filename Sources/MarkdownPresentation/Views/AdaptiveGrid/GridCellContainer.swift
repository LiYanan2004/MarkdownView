import SwiftUI

struct GridCellContainer: Identifiable {
    var id = UUID()
    var alignment: HorizontalAlignment
    var content: AnyView
    
    init(alignment: HorizontalAlignment = .center, @ViewBuilder content: () -> some View) {
        self.alignment = alignment
        self.content = AnyView(content())
    }
    
    init(alignment: HorizontalAlignment = .center, content: some View) {
        self.alignment = alignment
        self.content = AnyView(content)
    }
}
