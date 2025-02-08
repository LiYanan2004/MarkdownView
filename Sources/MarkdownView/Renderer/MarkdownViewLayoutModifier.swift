//
//  MarkdownViewLayoutModifier.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import SwiftUI

struct MarkdownViewLayoutViewModifier: ViewModifier {
    var role: MarkdownView.Role
    
    func body(content: Content) -> some View {
        content
            .frame(
                maxWidth: role == .editor ? .infinity : nil,
                maxHeight: role == .editor ? .infinity : nil,
                alignment: role == .editor ? .topLeading : .center
            )
    }
}

extension View {
    func markdownViewLayout(role: MarkdownView.Role) -> some View {
        modifier(MarkdownViewLayoutViewModifier(role: role))
    }
}
