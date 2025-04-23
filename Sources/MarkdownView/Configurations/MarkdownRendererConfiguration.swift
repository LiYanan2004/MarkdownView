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
    var fontGroup: AnyMarkdownFontGroup = AnyMarkdownFontGroup(.automatic)
    
    var listConfiguration: MarkdownListConfiguration = MarkdownListConfiguration()
    
    var allowedImageRenderers: Set<String> = ["https", "http"]
    var allowedBlockDirectiveRenderers: Set<String> = ["math"]
}



// MARK: - SwiftUI Environment

struct MarkdownRendererConfigurationKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: MarkdownRendererConfiguration = .init()
}

extension EnvironmentValues {
    var markdownRendererConfiguration: MarkdownRendererConfiguration {
        get { self[MarkdownRendererConfigurationKey.self] }
        set { self[MarkdownRendererConfigurationKey.self] = newValue }
    }
}
