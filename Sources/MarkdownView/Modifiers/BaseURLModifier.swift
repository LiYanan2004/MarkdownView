//
//  BaseURLModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {
    /// Sets the base URL used to resolve relative markdown links and image paths.
    ///
    /// - Parameter url: The base URL to use during rendering.
    nonisolated public func markdownBaseURL(_ url: URL) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.preferredBaseURL = url
        }
    }
    
    /// Sets the base URL used to resolve relative markdown links and image paths.
    ///
    /// - Parameter path: A URL string to use as the base URL during rendering.
    nonisolated public func markdownBaseURL(_ path: String) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.preferredBaseURL = URL(string: path)
        }
    }
}
