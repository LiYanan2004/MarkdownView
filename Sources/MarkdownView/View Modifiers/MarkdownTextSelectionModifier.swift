//
//  MarkdownTextSelectionModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/1/20.
//

import SwiftUI

extension SwiftUI.View {
    nonisolated public func markdownTextSelection(_ selection: some TextSelectability) -> some View {
        modifier(MarkdownTextSelectionViewModifier(selection: selection))
    }
}

nonisolated struct MarkdownTextSelectionViewModifier<S: TextSelectability>: ViewModifier {
    let selection: S
    
    func body(content: Content) -> some View {
        Group {
            if #available(iOS 26, macOS 26, *) {
                if type(of: selection).allowsSelection {
                    content
                        .environment(\.markdownViewRenderer, .textContent)
                } else {
                    content
                        .environment(\.markdownViewRenderer, .view)
                }
            } else {
                content
            }
        }
        .textSelection(selection)
    }
}
