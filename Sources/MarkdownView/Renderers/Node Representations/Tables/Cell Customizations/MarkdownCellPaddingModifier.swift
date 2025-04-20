//
//  MarkdownCellPaddingModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/20.
//

import SwiftUI

extension View {
    nonisolated func _markdownCellPadding(_ padding: MarkdownTableCellPadding) -> some View {
        modifier(MarkdownCellPaddingModifier(padding: padding))
    }
}

struct MarkdownCellPaddingModifier: ViewModifier {
    var padding: MarkdownTableCellPadding
    
    package func body(content: Content) -> some View {
        content
            .contentPadding(.top, padding[.top])
            .contentPadding(.bottom, padding[.bottom])
            .contentPadding(.leading, padding[.leading])
            .contentPadding(.trailing, padding[.trailing])
    }
}
