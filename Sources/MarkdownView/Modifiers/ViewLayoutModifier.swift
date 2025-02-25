//
//  ViewLayoutModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {
    ///  Configures the role of the markdown view.
    /// - Parameter role: A role to tell MarkdownView how to render its content.
    @available(*, deprecated, renamed: "markdownViewStyle", message: "Use markdownViewStyle instead.")
    @_documentation(visibility: internal)
    nonisolated public func markdownViewRole(
        _ role: MarkdownView.Role
    ) -> some View {
        self
    }
}
