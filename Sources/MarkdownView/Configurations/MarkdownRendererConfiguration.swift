//
//  MarkdownRendererConfiguration.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import Foundation
import SwiftUI

struct MarkdownRendererConfiguration: Equatable, Hashable, AllowingModifyThroughKeyPath, Sendable {
    var preferredBaseURL: URL?
    var componentSpacing: CGFloat = 8

    var math: Math = Math()

    var linkTintColor: Color = .accentColor
    var inlineCodeTintColor: Color = .accentColor
    var blockQuoteTintColor: Color = .accentColor

    var listConfiguration: MarkdownListConfiguration = MarkdownListConfiguration()

    var allowedImageRenderers: Set<String> = ["https", "http"]
    var allowedBlockDirectiveRenderers: Set<String> = ["math"]

    // Custom hash implementation for cache keys
    func hash(into hasher: inout Hasher) {
        hasher.combine(preferredBaseURL)
        hasher.combine(componentSpacing)
        hasher.combine(allowedImageRenderers)
        hasher.combine(allowedBlockDirectiveRenderers)
        // Note: Colors and Math config are not hashed as they typically don't affect caching
        // This is a performance optimization - add them if needed for your use case
    }
}

// MARK: - SwiftUI Environment

struct MarkdownRendererConfigurationKey: EnvironmentKey {
    static let defaultValue: MarkdownRendererConfiguration = .init()
}

extension EnvironmentValues {
    var markdownRendererConfiguration: MarkdownRendererConfiguration {
        get { self[MarkdownRendererConfigurationKey.self] }
        set { self[MarkdownRendererConfigurationKey.self] = newValue }
    }
}
