//
//  MarkdownViewStyleModifier.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import SwiftUI

extension View {
    nonisolated public func markdownViewStyle(_ style: some MarkdownViewStyle) -> some View {
        transformEnvironment(\.markdownViewStyle) { markdownViewStyle in
            markdownViewStyle = style
        }
    }
}

// MARK: - MarkdownViewStyle

/// The appearance and layout behavior of MarkdownView.
public protocol MarkdownViewStyle {
    /// A view that represents the apperance and layout behavior of a MarkdownView
    associatedtype Body: View
    /// The properties of a MarkdownView.
    typealias Configuration = MarkdownViewStyleConfiguration
    /// Creates a view that represents the body of a MarkdownView.
    func makeBody(configuration: Configuration) -> Body
}

/// The properties of a MarkdownView.
public struct MarkdownViewStyleConfiguration {
    private var _body: MarkdownNodeView
    public var body: some View {
        _body
    }
    
    internal init(body: @escaping () -> MarkdownNodeView) {
        self._body = body()
    }
}

// MARK: - DefaultMarkdownViewStyle

/// A MarkdownViewStyle that uses default appearances.
public struct DefaultMarkdownViewStyle: MarkdownViewStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.body
    }
}

extension MarkdownViewStyle where Self == DefaultMarkdownViewStyle {
    /// A MarkdownViewStyle that uses default appearances.
    static public var `default`: DefaultMarkdownViewStyle { .init() }
}

// MARK: - EditorMarkdownViewStyle

/// A MarkdownViewStyle that takes up all available spaces and align its content to top-leading, just like an editor.
public struct EditorMarkdownViewStyle: MarkdownViewStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.body
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

extension MarkdownViewStyle where Self == EditorMarkdownViewStyle {
    /// A MarkdownViewStyle that takes up all available spaces and align its content to top-leading, just like an editor.
    static public var editor: EditorMarkdownViewStyle { .init() }
}

// MARK: - MarkdownViewStyle + Environment

struct MarkdownViewStyleEnvironmentKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: any MarkdownViewStyle = .default
}

extension EnvironmentValues {
    var markdownViewStyle: any MarkdownViewStyle {
        get { self[MarkdownViewStyleEnvironmentKey.self] }
        set { self[MarkdownViewStyleEnvironmentKey.self] = newValue }
    }
}
