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
    nonisolated public func fontGroup(_ fontGroup: some MarkdownFontGroup) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.fonts = [
                .h1: fontGroup.h1,
                .h2: fontGroup.h2,
                .h3: fontGroup.h3,
                .h4: fontGroup.h4,
                .h5: fontGroup.h5,
                .h6: fontGroup.h6,
                .body: fontGroup.body,
                .codeBlock: fontGroup.codeBlock,
                .blockQuote: fontGroup.blockQuote,
                .tableHeader: fontGroup.tableHeader,
                .tableBody: fontGroup.tableBody,
                .inlineMath: fontGroup.inlineMath,
                .displayMath: fontGroup.displayMath,
            ]
        }
    }
    
    /// Sets the font for the specific component in MarkdownView.
    /// - Parameters:
    ///   - font: The font to apply to these components.
    ///   - component: The component to apply the font.
    nonisolated public func font(_ font: Font, for component: MarkdownComponent) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.fonts[component] = font
        }
    }
}
