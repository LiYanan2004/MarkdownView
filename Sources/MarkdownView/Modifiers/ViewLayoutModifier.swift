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
    public func markdownViewRole(
        _ role: MarkdownView.Role
    ) -> some View {
        #if os(watchOS)
        environment(\.markdownRendererConfiguration.role, .normal)
        #else
        environment(\.markdownRendererConfiguration.role, role)
        #endif
    }
    
    @available(macOS, unavailable)
    public func markdownViewLayout() -> some View {
        fatalError("Unimplemented")
    }
}
