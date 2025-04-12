//
//  MarkdownRenderConfiguration.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import Foundation
import SwiftUI

struct MarkdownRenderConfiguration: Equatable, AllowingModifyThroughKeyPath {
    var preferredBaseURL: URL? {
        willSet {
            imageRenderer.updateBaseURL(newValue)
        }
    }
    
    var rendersMathIfPossible = false
    
    // Spacing
    var componentSpacing: CGFloat = 8
    
    // Tint
    var inlineCodeTintColor: Color = .accentColor
    var blockQuoteTintColor: Color = .accentColor
    
    // Font & Foreground style
    var fontGroup: AnyMarkdownFontGroup = .init(.automatic)
    var foregroundStyleGroup: AnyMarkdownForegroundStyleGroup = .init(.automatic)
    
    // List
    var listConfiguration: MarkdownListConfiguration = .init()
    
    // Renderer
    var blockDirectiveRenderer: BlockDirectiveRenderer = .init()
    var imageRenderer: ImageRenderer = .init()
    
}

// MARK: - SwiftUI Environment

struct MarkdownRendererConfigurationKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: MarkdownRenderConfiguration = .init()
}

extension EnvironmentValues {
    var markdownRendererConfiguration: MarkdownRenderConfiguration {
        get { self[MarkdownRendererConfigurationKey.self] }
        set { self[MarkdownRendererConfigurationKey.self] = newValue }
    }
}
