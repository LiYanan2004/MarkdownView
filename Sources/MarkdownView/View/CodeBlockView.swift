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
        "\(colorScheme) mode" + (language ?? "No Language Name") + code
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
    
    private func highlight() {
        guard let highlighter = Highlightr.shared else { return }
        let language = self.language?.lowercased()
        let originalCode = code
        
        Task.detached { [language, highlighter] in
            let language = highlighter.supportedLanguages()
                .first(where: { $0.localizedLowercase == language })
            async let highlight = highlighter.highlight(originalCode, as: language)
            guard let highlightedCode = await highlight else { return }
            let attributedCode = AttributedString(highlightedCode)
            
            Task { @MainActor in
                withAnimation {
                    self.attributedCode = attributedCode
                }
            }
        }
    }
}
#endif

// MARK: - Shared Instance

#if canImport(Highlightr)
extension Highlightr {
    @MainActor
    static var shared: Highlightr? = Highlightr()
}
#endif

struct CodeHighlighterUpdator: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.codeHighlighterTheme) private var theme: CodeHighlighterTheme
    
    func body(content: Content) -> some View {
        content
            #if canImport(Highlightr)
            .task(id: colorScheme) {
                let theme = colorScheme == .dark ? theme.darkModeThemeName : theme.lightModeThemeName
                Highlightr.shared?.setTheme(to: theme)
            }
            .onChange(of: theme) { newTheme in
                let theme = colorScheme == .dark ? newTheme.darkModeThemeName : newTheme.lightModeThemeName
                Highlightr.shared?.setTheme(to: theme)
            }
            #endif
    }
}

extension View {
    func updateCodeBlocksWhenColorSchemeChanges() -> some View {
        modifier(CodeHighlighterUpdator())
    }
}
