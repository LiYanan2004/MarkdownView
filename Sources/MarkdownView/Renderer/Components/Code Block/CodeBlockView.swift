import SwiftUI

#if canImport(Highlightr)
@preconcurrency import Highlightr
#endif

#if canImport(Highlightr)
struct HighlightedCodeBlock: View {
    var language: String?
    var code: String
    
    @State private var showCopyButton = false
    @State private var attributedCode: AttributedString?
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    private var font: Font {
        configuration.fontGroup.codeBlock
    }
    
    var body: some View {
        Group {
            if let attributedCode {
                SwiftUI.Text(attributedCode)
            } else {
                SwiftUI.Text(code)
            }
        }
        .task {
            highlight(
                code: code,
                language: language,
                configuration: configuration
            )
        }
        .lineSpacing(5)
        .font(font)
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
    
    private func highlight(
        code: String,
        language: String?,
        configuration: MarkdownRenderConfiguration
    ) {
        let highlightr = Highlightr()!
        highlightr.setTheme(to: configuration.currentCodeHighlightTheme)
        
        let specifiedLanguage = language?.lowercased() ?? ""
        let language = highlightr.supportedLanguages()
            .first(where: { $0.localizedCaseInsensitiveCompare(specifiedLanguage) == .orderedSame })
        
        guard let highlightedCode = highlightr.highlight(code, as: language) else { return }
        let code = NSMutableAttributedString(
            attributedString: highlightedCode
        )
        code.removeAttribute(.font, range: NSMakeRange(0, code.length))
        
        attributedCode = AttributedString(code)
    }
}
#endif
