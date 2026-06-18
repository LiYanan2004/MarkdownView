//
//  MarkdownRendererConfiguration.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import Foundation
import SwiftUI
import MarkdownRenderingEssentials

package struct MarkdownRendererConfiguration: Hashable, AllowingModifyThroughKeyPath, Sendable {
    package var preferredBaseURL: URL?
    package var componentSpacing: CGFloat = 8
    
    package var math: Math = Math()
    package var tintColors: [MarkdownTintableComponent : Color] = [:]
    package var underlineLinks: Bool = false
    package var listConfiguration: MarkdownListConfiguration = MarkdownListConfiguration()
}

// MARK: - SwiftUI Environment

struct MarkdownRendererConfigurationKey: EnvironmentKey {
    package static let defaultValue: MarkdownRendererConfiguration = .init()
}

extension EnvironmentValues {
    package var markdownRendererConfiguration: MarkdownRendererConfiguration {
        get { self[MarkdownRendererConfigurationKey.self] }
        set { self[MarkdownRendererConfigurationKey.self] = newValue }
    }
}
