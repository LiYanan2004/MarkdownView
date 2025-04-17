//
//  BlockQuoteStyle.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/17.
//

import SwiftUI
import Markdown

/// A type that applies a custom style to all block quotes within a MarkdownView.
@preconcurrency
@MainActor
public protocol BlockQuoteStyle {
    /// A view that represents the current block quote.
    associatedtype Body: View
    /// Creates the view that represents the current block quote.
    @preconcurrency
    @MainActor
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body
    /// The properties of a block quote.
    typealias Configuration = BlockQuoteStyleConfiguration
}

/// The properties of a block quote.
public struct BlockQuoteStyleConfiguration {
    /// The content of a block quote.
    public var content: Content
    
    /// A type-erased content of a block quote
    public struct Content: View {
        private var blockQuote: BlockQuote
        @Environment(\.markdownRendererConfiguration) private var configuration
        
        init(blockQuote: BlockQuote) {
            self.blockQuote = blockQuote
        }
        
        @_documentation(visibility: internal)
        public var body: some View {
            VStack(alignment: .leading, spacing: configuration.componentSpacing) {
                ForEach(Array(blockQuote.children.enumerated()), id: \.offset) { _, child in
                    CmarkNodeVisitor(configuration: configuration)
                        .makeBody(for: child)
                }
            }
        }
    }
}

@available(*, unavailable)
extension BlockQuoteStyleConfiguration: Sendable {
    
}

// MARK: - Environment Value

struct BlockQuoteStyleKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: any BlockQuoteStyle = DefaultBlockQuoteStyle()
}

extension EnvironmentValues {
    package var blockQuoteStyle: any BlockQuoteStyle {
        get { self[BlockQuoteStyleKey.self] }
        set { self[BlockQuoteStyleKey.self] = newValue }
    }
}
