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

@_documentation(visibility: internal)
@available(*, deprecated, renamed: "MarkdownBlockQuoteStyle")
public typealias BlockQuoteStyle = MarkdownBlockQuoteStyle

// MARK: - Environment Value

struct BlockQuoteStyleKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: any MarkdownBlockQuoteStyle = DefaultBlockQuoteStyle()
}

extension EnvironmentValues {
    var blockQuoteStyle: any MarkdownBlockQuoteStyle {
        get { self[BlockQuoteStyleKey.self] }
        set { self[BlockQuoteStyleKey.self] = newValue }
    }
}
