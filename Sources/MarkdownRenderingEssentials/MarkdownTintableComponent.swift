//
//  MarkdownTintableComponent.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/15.
//

import Foundation

/// Components that can apply a tint color.
@_documentation(visibility: internal)
public enum MarkdownTintableComponent: Hashable, Sendable {
    case blockQuote
    case inlineCodeBlock
    case link
}
