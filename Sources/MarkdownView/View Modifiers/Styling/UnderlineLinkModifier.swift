//
//  UnderlineLinkModifier.swift
//  MarkdownView
//

import SwiftUI

extension View {
    /// Adds an underline decoration to links in the Markdown content.
    ///
    /// - Parameter isActive: Whether links should be underlined. Defaults to `true`.
    nonisolated public func underlineLinks(_ isActive: Bool = true) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.underlineLinks = isActive
        }
    }
}
