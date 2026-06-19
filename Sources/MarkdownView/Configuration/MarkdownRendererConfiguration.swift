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
    var underlineLinks: Bool = false
    var listConfiguration: MarkdownListConfiguration = MarkdownListConfiguration()
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
