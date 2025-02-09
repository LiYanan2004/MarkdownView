//
//  ListModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {
    public func markdownListIndent(_ indent: CGFloat) -> some View {
        self.environment(\.markdownRendererConfiguration.listConfiguration.listIndent, indent)
    }
    
    public func markdownUnorderedListBullet(_ bullet: String) -> some View {
        self.environment(\.markdownRendererConfiguration.listConfiguration.unorderedListBullet, bullet)
    }
    
    public func markdownComponentSpacing(_ spacing: CGFloat) -> some View {
        self.environment(\.markdownRendererConfiguration.componentSpacing, spacing)
    }
}
