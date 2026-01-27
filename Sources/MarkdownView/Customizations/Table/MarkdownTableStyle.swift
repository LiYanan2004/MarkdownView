//
//  MarkdownTableStyle.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/17.
//

import SwiftUI
import Markdown

/// A type that applies a cutsom appearance to all tables created by MarkdownView within the view hierarchy.
/// 
/// Think of this type as a SwiftUI View wrapper.
///
/// Don't directly access view dependencies (e.g. `@Environment`), use a separate view instead.
@preconcurrency
@MainActor
public protocol MarkdownTableStyle {
    /// A view that represents the markdown table.
    associatedtype Body : SwiftUI.View
    
    /// Creates the view that represents the current markdown table.
    ///
    /// It's recommended to use `Grid` to construct a table, but since `Grid` is only available for iOS 16, macOS 13, tvOS 16 and watchOS 9, you will need to use ``MarkdownTableStyleConfiguration/Table/Fallback`` on older platforms.
    @preconcurrency
    @MainActor
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body
    
    /// The properties of a markdown table.
    typealias Configuration = MarkdownTableStyleConfiguration
}

// MARK: - Environment Value

struct MarkdownTableStyleKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: any MarkdownTableStyle = DefaultMarkdownTableStyle()
}

extension EnvironmentValues {
    package var markdownTableStyle: any MarkdownTableStyle {
        get { self[MarkdownTableStyleKey.self] }
        set { self[MarkdownTableStyleKey.self] = newValue }
    }
}
