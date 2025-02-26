//
//  View++.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/2/25.
//

import SwiftUI

// MARK: - AnyView

extension View {
    @_spi(Internal)
    nonisolated public func erasedToAnyView() -> AnyView {
        AnyView(self)
    }
}

// MARK: - Conditional Content

extension View {
    @ViewBuilder
    func `if`(_ condition: @autoclosure @escaping () -> Bool, @ViewBuilder content: @escaping (_ content: Self) -> some View) -> some View {
        if condition() {
            content(self)
        } else {
            self
        }
    }
}
