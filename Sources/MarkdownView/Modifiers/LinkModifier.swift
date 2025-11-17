//
//  LinkModifier.swift
//  MarkdownView
//
//  Created by Mahdi BND on 11/17/25.
//

import SwiftUI

extension View {
    /// Sets the style of block quotes within a MarkdownView.
    nonisolated public func linkStyle(_ style: some LinkStyle) -> some View {
        environment(\.linkStyle, style)
    }
}
