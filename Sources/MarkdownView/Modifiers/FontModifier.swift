//
//  FontModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {
    
    /// Apply a font group to MarkdownView.
    ///
    /// Customize fonts for multiple types of text.
    ///
    /// - Parameter fontGroup: A font set to apply to the MarkdownView.
    public func fontGroup(_ fontGroup: some MarkdownFontGroup) -> some View {
        environment(\.markdownRendererConfiguration.fontGroup, .init(fontGroup))
    }
    
    /// Sets the font for the specific component in MarkdownView.
    /// - Parameters:
    ///   - font: The font to apply to these components.
    ///   - type: The type of components to apply the font.
    public func font(_ font: Font, for type: MarkdownTextType) -> some View {
        transformEnvironment(\.markdownRendererConfiguration.fontGroup) { fontGroup in
            switch type {
            case .h1: fontGroup._h1 = font
            case .h2: fontGroup._h2 = font
            case .h3: fontGroup._h3 = font
            case .h4: fontGroup._h4 = font
            case .h5: fontGroup._h5 = font
            case .h6: fontGroup._h6 = font
            case .body: fontGroup._body = font
            case .blockQuote: fontGroup._blockQuote = font
            case .codeBlock: fontGroup._codeBlock = font
            case .tableBody: fontGroup._tableBody = font
            case .tableHeader: fontGroup._tableHeader = font
            }
        }
    }
    
}
