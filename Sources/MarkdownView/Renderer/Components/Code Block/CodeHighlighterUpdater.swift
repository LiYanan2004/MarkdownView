#if canImport(Highlightr)
@preconcurrency import Highlightr
#endif
import SwiftUI

/// A responder that update the theme of highlightr when environment value changes.
struct CodeHighlighterUpdater: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.markdownRendererConfiguration) private var configuration
    
    @State private var highlightrUpdateTaskCache: Task<Void, Error>?
    
    func body(content: Content) -> some View {
        content
            #if canImport(Highlightr)
            .onChange(of: colorScheme) { colorScheme in
                highlightrUpdateTaskCache?.cancel()
                highlightrUpdateTaskCache = Task {
                    let theme = colorScheme == .dark ? configuration.codeBlockTheme.darkModeThemeName : configuration.codeBlockTheme.lightModeThemeName
                    let highlighr = await Highlightr.shared.value
                    try Task.checkCancellation()
                    highlighr?.setTheme(to: theme)
                }
            }
            .onChange(of: configuration.codeBlockTheme) { newTheme in
                highlightrUpdateTaskCache?.cancel()
                highlightrUpdateTaskCache = Task {
                    let theme = colorScheme == .dark ? newTheme.darkModeThemeName : newTheme.lightModeThemeName
                    let highlighr = await Highlightr.shared.value
                    try Task.checkCancellation()
                    highlighr?.setTheme(to: theme)
                }
            }
            #endif
    }
}
