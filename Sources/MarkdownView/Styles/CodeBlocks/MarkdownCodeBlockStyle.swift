//
//  MarkdownCodeBlockStyle.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/3/25.
//

import SwiftUI

/// A type that applies a custom style to all code blocks within a MarkdownView.
///
/// Think of this type as a SwiftUI View wrapper.
///
/// Don't directly access view dependencies (e.g. `@Environment`), use a separate view instead.
@preconcurrency
@MainActor
public protocol MarkdownCodeBlockStyle {
    /// A view that represents the current code block.
    associatedtype Body: View
    /// Creates the view that represents the current code block.
    @preconcurrency
    @MainActor
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body
    /// The properties of a code block.
    typealias Configuration = MarkdownCodeBlockStyleConfiguration
}

@_documentation(visibility: internal)
@available(*, deprecated, renamed: "MarkdownCodeBlockStyle")
public typealias CodeBlockStyle = MarkdownCodeBlockStyle

// MARK: - Environment Value

struct CodeBlockStyleKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: any MarkdownCodeBlockStyle = DefaultCodeBlockStyle()
}

extension EnvironmentValues {
    var codeBlockStyle: any MarkdownCodeBlockStyle {
        get { self[CodeBlockStyleKey.self] }
        set { self[CodeBlockStyleKey.self] = newValue }
    }
}
