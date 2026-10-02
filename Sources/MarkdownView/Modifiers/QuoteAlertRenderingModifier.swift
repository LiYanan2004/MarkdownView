//
//  QuoteAlertRenderingModifier.swift
//  MarkdownView
//

import SwiftUI

extension View {
    /// Enables or disables GitHub-style quote alert (e.g. `[!NOTE]`, `[!WARNING]`) rendering.
    ///
    /// - parameter enabled: A Boolean value that indicates whether to detect and render
    ///   GitHub-style quote alerts. The default value is `true`.
    nonisolated public func markdownQuoteAlertEnabled(_ enabled: Bool = true) -> some View {
        transformEnvironment(\.markdownQuoteAlertEnabled) { $0 = enabled }
    }
}

// MARK: - Environment

extension EnvironmentValues {
    @Entry var markdownQuoteAlertEnabled: Bool = false
}
