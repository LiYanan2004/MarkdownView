//
//  MarkdownRendererConfiguration.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import Foundation
import SwiftUI

struct MarkdownRendererConfiguration: Hashable, AllowingModifyThroughKeyPath, Sendable {
    var preferredBaseURL: URL?
    var componentSpacing: CGFloat = 8
    
    var math: Math = Math()
    var tintColors: [MarkdownTintableComponent : Color] = [:]
    var listConfiguration: MarkdownListConfiguration = MarkdownListConfiguration()
}

// MARK: - MarkdownTintableComponent

@available(*, deprecated, renamed: "MarkdownTintableComponent")
public typealias TintableComponent = MarkdownTintableComponent

/// Components that can apply a tint color.
@_documentation(visibility: internal)
public enum MarkdownTintableComponent: Hashable, Sendable {
    case blockQuote
    case inlineCodeBlock
    case link
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
