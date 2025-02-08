import Markdown
import SwiftUI
#if canImport(Highlightr)
@preconcurrency import Highlightr
#endif

// MARK: - Code Block

extension Renderer {
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> Result {
        Result {
            #if canImport(Highlightr)
            HighlightedCodeBlock(
                language: codeBlock.language,
                code: codeBlock.code,
                theme: configuration.codeBlockTheme
            ).modifier(CodeHighlighterUpdater())
            #else
            SwiftUI.Text(codeBlock.code)
            #endif
        }
    }
    
    func visitHTMLBlock(_ html: HTMLBlock) -> Result {
        Result {
            SwiftUI.Text(html.rawHTML)
        }
    }
}

// MARK: - Auxiliary

fileprivate struct CodeHighlighterUpdater: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.markdownRendererConfiguration) private var configuration
    
    @State private var highlightrUpdateTaskCache: Task<Void, Error>?
    
    func body(content: Content) -> some View {
        content
            #if canImport(Highlightr)
            .onChange(of: colorScheme) {
                updateTheme()
            }
            .onChange(of: configuration.codeBlockTheme) {
                updateTheme()
            }
            #endif
    }
    
    private func updateTheme() {
        highlightrUpdateTaskCache?.cancel()
        highlightrUpdateTaskCache = Task {
            let theme = colorScheme == .dark ? configuration.codeBlockTheme.darkModeThemeName : configuration.codeBlockTheme.lightModeThemeName
            let highlighr = await Highlightr.shared.value
            try Task.checkCancellation()
            highlighr?.setTheme(to: theme)
        }
    }
}
