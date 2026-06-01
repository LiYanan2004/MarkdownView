//
//  DeprecatedAPIs.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/2/26.
//

import SwiftUI
import Markdown

extension View {
    /// Registers a legacy block directive renderer.
    ///
    /// - Parameter renderer: The legacy renderer to use for matching block directives.
    /// - Parameter name: The block directive name to match.
    /// - Returns: A view that uses the specified legacy renderer.
    @available(*, unavailable, message: "Use markdownElementRenderer(.blockDirective(_:name:)) instead.")
    nonisolated public func blockDirectiveProvider(
        _ renderer: some BlockDirectiveDisplayable,
        for name: String
    ) -> some View {
        fatalError()
    }
    
    /// Registers a legacy image renderer.
    ///
    /// - Parameter provider: The legacy renderer to use for matching image URLs.
    /// - Parameter urlScheme: The URL scheme to match.
    /// - Returns: A view that uses the specified legacy renderer.
    @available(*, unavailable, message: "Use markdownElementRenderer(.image(_:urlScheme:)) instead.")
    nonisolated public func imageProvider(
        _ provider: some ImageDisplayable, forURLScheme urlScheme: String
    ) -> some View {
        fatalError()
    }
}

/// A legacy protocol that renders markdown images.
@available(*, unavailable, renamed: "MarkdownImageRenderer")
public protocol ImageDisplayable {
    /// The view that represents the rendered image.
    associatedtype ImageView: View
    
    /// Creates a view that represents the image.
    ///
    /// - Parameter url: The source URL of the image.
    /// - Parameter alt: The alternative text of the image.
    /// - Returns: A view that renders the image.
    @ViewBuilder func makeImage(url: URL, alt: String?) -> ImageView
}

/// A legacy protocol that renders markdown block directives.
@available(*, unavailable, renamed: "BlockDirectiveRenderer")
public protocol BlockDirectiveDisplayable {
    /// The view that represents the rendered block directive.
    associatedtype BlockDirectiveView: View
    
    /// Creates a view that represents the block directive.
    ///
    /// - Parameter arguments: The arguments defined by the block directive.
    /// - Parameter text: The source text wrapped by the block directive.
    /// - Returns: A view that renders the block directive.
    @ViewBuilder func makeView(
        arguments: [BlockDirectiveArgument],
        text: String
    ) -> BlockDirectiveView
}

/// A legacy value that describes a block directive argument.
@available(*, unavailable, renamed: "BlockDirectiveRendererConfiguration.Argument")
public struct BlockDirectiveArgument {
    /// The name of the argument.
    public var name: String
    
    /// The value of that argument.
    public var value: String
    
    /// An argument that represented from ``Markdown/DirectiveArgument``.
    /// - Parameter directiveArgument: The `DirectiveArgument` of the directive block.
    init(_ directiveArgument: DirectiveArgument) {
        name = directiveArgument.name
        value = directiveArgument.value
    }
}
