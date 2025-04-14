//
//  MarkdownRenderConfiguration.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import Foundation
import SwiftUI

struct MarkdownRenderConfiguration: Equatable, AllowingModifyThroughKeyPath, Sendable {
    var preferredBaseURL: URL?
    var componentSpacing: CGFloat = 8
    
    var mathRenderingConfiguration: MathRenderingConfiguration = MathRenderingConfiguration()
    
    var inlineCodeTintColor: Color = .accentColor
    var blockQuoteTintColor: Color = .accentColor
    var fontGroup: AnyMarkdownFontGroup = AnyMarkdownFontGroup(.automatic)
    var foregroundStyleGroup: AnyMarkdownForegroundStyleGroup = AnyMarkdownForegroundStyleGroup(.automatic)
    
    var listConfiguration: MarkdownListConfiguration = MarkdownListConfiguration()
    
    var allowedImageRenderers: Set<String> = ["https", "http"]
    var allowedBlockDirectiveRenderers: Set<String> = ["math"]
}

extension MarkdownRenderConfiguration {
    struct MathRenderingConfiguration: Sendable, Hashable {
        var enabled: Bool {
            get { displayMathStorage != nil }
            set(enabled) {
                if enabled {
                    displayMathStorage = [:]
                } else {
                    displayMathStorage = nil
                }
            }
        }
        var displayMathStorage: [UUID : String]? = nil
        
        mutating func appendDisplayMath(_ displayMath: some StringProtocol) -> UUID {
            if displayMathStorage == nil {
                displayMathStorage = [:]
            }
            
            let id = UUID()
            displayMathStorage![id] = String(displayMath)
            return id
        }
    }
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
