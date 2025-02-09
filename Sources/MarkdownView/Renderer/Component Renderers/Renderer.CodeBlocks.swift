import Markdown
import SwiftUI
#if canImport(Highlightr)
@preconcurrency import Highlightr
#endif

extension MarkdownViewRenderer {
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> Result {
        Result {
            SwiftUI.Text(codeBlock.code)
//            #if canImport(Highlightr)
//            HighlightedCodeBlock(
//                language: codeBlock.language,
//                code: codeBlock.code,
//                theme: configuration.codeBlockTheme
//            ).modifier(CodeHighlighterUpdater())
//            #else
//            
//            #endif
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
    @Environment(\.markdownRendererConfiguration) private var rendererConfiguration
    private var codeBlockConfiguration: CodeBlockConfiguration {
        CodeBlockConfiguration(
            theme: rendererConfiguration.codeBlockTheme,
            colorScheme: colorScheme
        )
    }
    
    @State private var highlightrUpdateTaskCache: Task<Void, Error>?
    
    func body(content: Content) -> some View {
        content
            #if canImport(Highlightr)
            .task(id: codeBlockConfiguration) {
                updateTheme()
            }
            #endif
    }
    
    #if canImport(Highlightr)
    private func updateTheme() {
        highlightrUpdateTaskCache?.cancel()
        highlightrUpdateTaskCache = Task.detached { [codeBlockConfiguration] in
            let highlighr = await Highlightr.shared.value
            try Task.checkCancellation()
            highlighr?.setTheme(to: codeBlockConfiguration.currentThemeName)
        }
    }
    #endif
}

extension CodeHighlighterUpdater {
    struct CodeBlockConfiguration: Equatable, Sendable {
        var theme: CodeHighlighterTheme
        var colorScheme: ColorScheme
        
        var currentThemeName: String {
            colorScheme == .dark ? theme.darkModeThemeName : theme.lightModeThemeName
        }
    }
}
