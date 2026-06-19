//
//  UnderlineLinkModifier.swift
//  MarkdownView
//

import SwiftUI

extension SwiftUI.View {
    /// Adds an underline decoration to links in the Markdown content.
    ///
    /// - Parameter isActive: Whether links should be underlined. Defaults to `true`.
    nonisolated public func markdownLinksUnderlined(_ isActive: Bool = true) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.underlineLinks = isActive
        }
    }
}
