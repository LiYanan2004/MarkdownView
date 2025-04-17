//
//  CodeBlockStyle.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/3/25.
//

import SwiftUI

/// A type that applies a custom style to all code blocks within a MarkdownView.
@preconcurrency
@MainActor
public protocol CodeBlockStyle {
    /// A view that represents the current code block.
    associatedtype Body: View
    /// Creates the view that represents the current code block.
    @preconcurrency
    @MainActor
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body
    /// The properties of a code block.
    typealias Configuration = CodeBlockStyleConfiguration
}

/// The properties of a code block.
public struct CodeBlockStyleConfiguration: Hashable, Sendable, Codable {
    public var language: String?
    public var code: String
}

// MARK: - Environment Value

struct CodeBlockStyleKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: any CodeBlockStyle = DefaultCodeBlockStyle()
}

extension EnvironmentValues {
    package var codeBlockStyle: any CodeBlockStyle {
        get { self[CodeBlockStyleKey.self] }
        set { self[CodeBlockStyleKey.self] = newValue }
    }
}
