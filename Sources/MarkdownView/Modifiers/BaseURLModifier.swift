//
//  BaseURLModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {
    nonisolated public func markdownBaseURL(_ url: URL) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.preferredBaseURL = url
        }
    }
}
