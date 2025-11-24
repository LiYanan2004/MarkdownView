//
//  MarkdownViewStyleModifier.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import SwiftUI

extension View {
    @available(*, deprecated, message: "Wrap `MarkdownView` or apply modifiers directly at here. If you have already created a `MarkdownViewStyle`, just copy the code from `makeBody(configuration:) -> Body` and copy to here.")
    nonisolated public func markdownViewStyle(_ style: some MarkdownViewStyle) -> some View {
        environment(\.markdownViewStyle, style)
    }
}

// MARK: - MarkdownViewStyle

/// The appearance and layout behavior of MarkdownView.
@MainActor
@preconcurrency
@available(*, deprecated, message: "Use `ViewModifier` protocol instead.")
public protocol MarkdownViewStyle {
    /// The properties of a MarkdownView.
    typealias Configuration = MarkdownViewStyleConfiguration
    
    /// Creates a view that represents the body of a MarkdownView.
    @MainActor
    @preconcurrency
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body
    
    /// A view that represents the apperance and layout behavior of a MarkdownView
    associatedtype Body: View
}

/// The properties of a MarkdownView.
public struct MarkdownViewStyleConfiguration {
    private var _body: AnyView
    public var body: some View {
        _body
    }
    
    internal init<Content: View>(body: Content) {
        self._body = body.erasedToAnyView()
    }
}

// MARK: - DefaultMarkdownViewStyle

/// A MarkdownViewStyle that uses default appearances.
@available(*, deprecated)
public struct DefaultMarkdownViewStyle: MarkdownViewStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.body
    }
}

@available(*, deprecated)
extension MarkdownViewStyle where Self == DefaultMarkdownViewStyle {
    /// A MarkdownViewStyle that uses default appearances.
    static public var `default`: DefaultMarkdownViewStyle { .init() }
}

// MARK: - EditorMarkdownViewStyle

/// A MarkdownViewStyle that takes up all available spaces and align its content to top-leading, just like an editor.
@available(*, deprecated, message: "Use `.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)` instead.")
public struct EditorMarkdownViewStyle: MarkdownViewStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.body
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

@available(*, deprecated)
extension MarkdownViewStyle where Self == EditorMarkdownViewStyle {
    /// A MarkdownViewStyle that takes up all available spaces and align its content to top-leading, just like an editor.
    static public var editor: EditorMarkdownViewStyle { .init() }
}

// MARK: - MarkdownViewStyle + Environment

@available(*, deprecated)
struct MarkdownViewStyleEnvironmentKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: any MarkdownViewStyle = .default
}

extension EnvironmentValues {
    @available(*, deprecated)
    var markdownViewStyle: any MarkdownViewStyle {
        get { self[MarkdownViewStyleEnvironmentKey.self] }
        set { self[MarkdownViewStyleEnvironmentKey.self] = newValue }
    }
}
