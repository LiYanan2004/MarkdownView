import SwiftUI

struct ViewWithBackground: View {
    var arguments: [MarkdownDirectiveBlockHandler.Argument]
    var wrappedView: any View
    
    var body: some View {
        ZStack {
            background
            AnyView(wrappedView)
                .scenePadding()
                .foregroundColor(textForegroundColor)
        }
    }
    
    var background: some View {
        ColorRepresentble(from: arguments.first?.value ?? "Red")
    }
    
    var textForegroundColor: Color {
        if arguments.count == 1 { return .primary }
        else { return ColorRepresentble(from: arguments.last?.value ?? "primary") }
    }
    
    func ColorRepresentble(from text: String) -> Color {
        switch text.lowercased() {
        case "red": return Color.red
        case "orange": return Color.orange
        case "yellow": return Color.yellow
        case "green": return Color.green
        case "blue": return Color.blue
        case "indigo": return Color.indigo
        case "purple": return Color.purple
        case "cyan": return Color.cyan
        case "mint": return Color.mint
        case "pink": return Color.pink
        case "black": return Color.black
        case "gray": return Color.gray
        case "brown": return Color.brown
        case "primary": return Color.primary
        case "secondary": return Color.secondary
        case "white": return Color.white
        default:
#if os(macOS)
            return Color(nsColor: .windowBackgroundColor)
#elseif os(iOS) || os(tvOS)
            return Color(uiColor: .systemBackground)
#endif
        }
    }
}
