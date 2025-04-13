//
//  DeprecatedAPIs.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/2/26.
//

import SwiftUI
import Markdown

extension View {
    @available(*, unavailable, renamed: "blockDirectiveRenderer")
    nonisolated public func blockDirectiveProvider(
        _ renderer: some BlockDirectiveDisplayable, for name: String
    ) -> some View {
        fatalError()
    }
    
    @available(*, unavailable, renamed: "markdownImageRenderer")
    nonisolated public func imageProvider(
        _ provider: some ImageDisplayable, forURLScheme urlScheme: String
    ) -> some View {
        fatalError()
    }
}

@available(*, unavailable, renamed: "MarkdownImageRenderer")
public protocol ImageDisplayable {
    associatedtype ImageView: View
    
    /// Creates a view that represents the image.
    @ViewBuilder func makeImage(url: URL, alt: String?) -> ImageView
}

@available(*, unavailable, renamed: "BlockDirectiveRenderer")
public protocol BlockDirectiveDisplayable {
    associatedtype BlockDirectiveView: View
    
    @ViewBuilder func makeView(
        arguments: [BlockDirectiveArgument],
        text: String
    ) -> BlockDirectiveView
}

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
