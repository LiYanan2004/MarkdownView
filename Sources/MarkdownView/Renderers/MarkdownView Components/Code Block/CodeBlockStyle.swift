//
//  CodeBlockStyle.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/3/25.
//

import SwiftUI

/// A type that applies a custom style to all code blocks within a MarkdownView.
public protocol CodeBlockStyle {
    /// A view that represents the current code block.
    associatedtype Body: View
    /// Creates the view that represents the current code block.
    func makeBody(configuration: Configuration) -> Body
    /// The properties of a code block.
    typealias Configuration = CodeBlockStyleConfiguration
}

/// The properties of a code block.
public struct CodeBlockStyleConfiguration {
    public var language: String?
    public var code: String
}

// MARK: - Environment Value

extension EnvironmentValues {
    @Entry var codeBlockStyle: any CodeBlockStyle = DefaultCodeBlockStyle()
}
