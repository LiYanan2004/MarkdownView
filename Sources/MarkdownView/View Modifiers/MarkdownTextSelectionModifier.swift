//
//  MarkdownTextSelectionModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/1/20.
//

import SwiftUI

extension SwiftUI.View {
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    nonisolated public func markdownTextSelection(_ selection: some TextSelectability) -> some View {
        modifier(MarkdownTextSelectionViewModifier(selection: selection))
    }
}

@available(tvOS, unavailable)
@available(watchOS, unavailable)
nonisolated struct MarkdownTextSelectionViewModifier<S: TextSelectability>: ViewModifier {
    let selection: S
    
    func body(content: Content) -> some View {
        Group {
            #if canImport(RichText)
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
            #else
            content
            #endif
        }
        .textSelection(selection)
    }
}
