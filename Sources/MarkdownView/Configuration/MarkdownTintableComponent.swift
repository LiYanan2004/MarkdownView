//
//  MarkdownTintableComponent.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

/// Components that can apply a tint color.
@_documentation(visibility: internal)
public enum MarkdownTintableComponent: Hashable, Sendable {
    case blockQuote
    case inlineCodeBlock
    case link
}

@_documentation(visibility: internal)
@available(*, deprecated, renamed: "MarkdownTintableComponent")
public typealias TintableComponent = MarkdownTintableComponent
