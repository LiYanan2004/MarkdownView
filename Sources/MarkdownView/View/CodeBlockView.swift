import SwiftUI

#if canImport(Highlightr)
@preconcurrency import Highlightr
#endif

#if canImport(Highlightr)
struct HighlightedCodeBlock: View {
    var language: String?
    var code: String
    var theme: CodeHighlighterTheme
    
    @Environment(\.fontGroup) private var font
    @Environment(\.colorScheme) private var colorScheme
    @State private var attributedCode: AttributedString?
    @State private var showCopyButton = false
    
    private var id: String {
        "\(colorScheme) mode" + (language ?? "Plain Text") + code
    }

    var body: some View {
        Group {
            if let attributedCode {
                SwiftUI.Text(attributedCode)
            } else {
                SwiftUI.Text(code)
            }
        }
        .task(id: id, highlight)
        .lineSpacing(5)
        .font(font.codeBlock)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
        .gesture(
            TapGesture()
                .onEnded { _ in showCopyButton.toggle() }
        )
        .overlay(alignment: .topTrailing) {
            if showCopyButton {
                CopyButton(content: code)
                    .padding(8)
                    .transition(.opacity.animation(.easeInOut))
            }
        }
        .overlay(alignment: .bottomTrailing) {
            codeLanguage
        }
        .onHover { showCopyButton = $0 }
    }
    
    @ViewBuilder
    private var codeLanguage: some View {
        if let language {
            SwiftUI.Text(language.uppercased())
                .font(.callout)
                .padding(8)
                .foregroundStyle(.secondary)
        }
    }
    
    private func highlight() async {
        guard let highlighter = await Highlightr.shared.value else { return }
        let specifiedLanguage = self.language?.lowercased() ?? ""
        
        let language = highlighter.supportedLanguages()
            .first(where: { $0.localizedCaseInsensitiveCompare(specifiedLanguage) == .orderedSame })
        if let highlightedCode = highlighter.highlight(code, as: language) {
            let code = NSMutableAttributedString(attributedString: highlightedCode)
            code.removeAttribute(.font, range: NSMakeRange(0, code.length))
            attributedCode = AttributedString(code)
        }
    }
}
#endif
