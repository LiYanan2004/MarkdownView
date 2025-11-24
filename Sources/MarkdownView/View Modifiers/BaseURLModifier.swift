//
//  BaseURLModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {
    /// Sets the base URL used to resolve relative image paths inside Markdown.
    ///
    /// Markdown image elements that omit a scheme (for example `images/logo.png`)
    /// are only displayable once they are resolved against a base URL. Use this
    /// modifier whenever your Markdown references local documentation assets or
    /// CDN paths.
    ///
    /// ```swift
    /// MarkdownView(markdown)
    ///     .markdownBaseURL(Bundle.main.bundleURL)
    /// // Markdown: ![Diagram](Resources/diagram.svg)
    /// ```
    ///
    /// - Parameter url: The base location that relative URLs are resolved
    ///   against. Only the scheme/host/path are used; query parameters are
    ///   preserved when the Markdown specifies them.
    nonisolated public func markdownBaseURL(_ url: URL) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.preferredBaseURL = url
        }
    }
    
    /// Convenience overload that creates the base URL from a string.
    ///
    /// If the string cannot be converted into a valid `URL`, the modifier is a
    /// no-op.
    ///
    /// - Parameter path: The raw string representation of the base URL.
    nonisolated public func markdownBaseURL(_ path: String) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.preferredBaseURL = URL(string: path)
        }
    }
}
