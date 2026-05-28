//
//  MarkdownRendererConfiguration.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import Foundation
import SwiftUI

struct MarkdownRendererConfiguration: Equatable, AllowingModifyThroughKeyPath, Sendable {
    var preferredBaseURL: URL?
    var componentSpacing: CGFloat = 8
    
    var math: Math = Math()
    
    var linkTintColor: Color = .accentColor
    var inlineCodeTintColor: Color = .accentColor
    var blockQuoteTintColor: Color = .accentColor
    
    var listConfiguration: MarkdownListConfiguration = MarkdownListConfiguration()
    
    var allowedImageRenderers: Set<String> = ["https", "http"]
    /// Custom link renderers keyed by URL scheme (or `"*"` wildcard).
    /// Replaces the previous singleton `MarkdownLinkRenders.shared` so each
    /// SwiftUI subtree carries its own renderer registration through the
    /// environment — two `.markdownLinkRenderer(...)` calls in different
    /// subtrees no longer race on a global last-writer-wins dictionary.
    /// Dictionary keys are the allow-list; absence means the default
    /// (Branch A) text rendering applies.
    var linkRenderers: [String: AnyMarkdownLinkRenderer] = [:]
    var allowedBlockDirectiveRenderers: Set<String> = []
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
