//
//  RendererConfiguration.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import Foundation
import SwiftUI

extension MarkdownView {
    struct RendererConfiguration: Equatable, AllowingModifyThroughKeyPath {
        var role: MarkdownView.Role = .normal
        var preferredBaseURL: URL? {
            willSet {
                imageRenderer.updateBaseURL(newValue)
            }
        }
        
        // Spacing
        var lineSpacing: CGFloat? = nil
        var componentSpacing: CGFloat = 8
        
        mutating func withLineSpacing(_ lineSpacing: CGFloat) {
            self.lineSpacing = lineSpacing
        }
        
        // Tint
        var inlineCodeTintColor: Color = .accentColor
        var blockQuoteTintColor: Color = .accentColor
        
        // Font & Foreground style
        var fontGroup: AnyMarkdownFontGroup = .init(.automatic)
        var foregroundStyleGroup: AnyMarkdownForegroundStyleGroup = .init(.automatic)
        
        // Code Block
        var codeBlockTheme: CodeHighlighterTheme = .init(
            lightModeThemeName: "xcode", darkModeThemeName: "dark"
        )
        
        // List
        var listConfiguration: MarkdownListConfiguration = .init()
        
        // Renderer
        var blockDirectiveRenderer: BlockDirectiveRenderer = .init()
        var imageRenderer: ImageRenderer = .init()
        
        
    }
}
