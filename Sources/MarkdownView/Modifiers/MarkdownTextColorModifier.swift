import SwiftUI

extension SwiftUI.View {
    /// Sets the default color of text and embedded views in `MarkdownText`.
    ///
    /// `MarkdownText` uses the primary text color by default and isolates its content from inherited foreground styles. Explicit colors in links, inline code, and custom embedded views take precedence.
    ///
    /// - Parameter color: The default foreground color for the rendered content.
    nonisolated public func markdownTextColor(_ color: Color) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.textColor = color
        }
    }
}
