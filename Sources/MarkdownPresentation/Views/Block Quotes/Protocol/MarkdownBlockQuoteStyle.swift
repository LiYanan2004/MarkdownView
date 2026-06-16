//
//  MarkdownBlockQuoteStyle.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/17.
//

import SwiftUI

/// A type that applies a custom style to all block quotes within a MarkdownView.
///
/// Think of this type as a SwiftUI View wrapper.
///
/// Don't directly access view dependencies (e.g. `@Environment`), use a separate view instead.
@preconcurrency
@MainActor
public protocol MarkdownBlockQuoteStyle {
    /// A view that represents the current block quote.
    associatedtype Body: View
    /// Creates the view that represents the current block quote.
    @preconcurrency
    @MainActor
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body
    /// The properties of a block quote.
    typealias Configuration = MarkdownBlockQuoteStyleConfiguration
}

/// The properties of a block quote.
public struct MarkdownBlockQuoteStyleConfiguration {
    /// The content of a block quote.
    public var content: Content
    
    /// A type-erased content of a block quote
    public struct Content: View {
        private var content: AnyView
        
        package init(@ViewBuilder _ content: () -> some View) {
            self.content = AnyView(content())
        }
        
        @_documentation(visibility: internal)
        public var body: some View {
            content
        }
    }
}

@available(*, unavailable)
extension MarkdownBlockQuoteStyleConfiguration: Sendable {
    
}

@_documentation(visibility: internal)
@available(*, deprecated, renamed: "MarkdownBlockQuoteStyle")
public typealias BlockQuoteStyle = MarkdownBlockQuoteStyle

@_documentation(visibility: internal)
@available(*, deprecated, renamed: "MarkdownBlockQuoteStyleConfiguration")
public typealias BlockQuoteStyleConfiguration = MarkdownBlockQuoteStyleConfiguration

// MARK: - Environment Value

struct BlockQuoteStyleKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: any MarkdownBlockQuoteStyle = DefaultBlockQuoteStyle()
}

extension EnvironmentValues {
    package var blockQuoteStyle: any MarkdownBlockQuoteStyle {
        get { self[BlockQuoteStyleKey.self] }
        set { self[BlockQuoteStyleKey.self] = newValue }
    }
}
