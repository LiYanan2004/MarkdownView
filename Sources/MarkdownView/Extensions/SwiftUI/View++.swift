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
