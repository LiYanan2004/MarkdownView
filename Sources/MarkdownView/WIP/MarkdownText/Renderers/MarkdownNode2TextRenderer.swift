//
//  MarkdownNode2TextRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/12.
//

import Foundation
import SwiftUI

protocol MarkdownNode2TextRenderer: DynamicProperty {
    typealias Context = MarkdownNode2TextRendererContext
    
    @TextBuilder func body(context: Context) -> Text
}

struct MarkdownNode2TextRendererContext: Sendable {
    var node: MarkdownTextNode
    var renderConfiguration: MarkdownRenderConfiguration
}

// MARK: - Auxiliary

@resultBuilder
struct TextBuilder {
    static func buildBlock(_ components: Text...) -> Text {
        components.reduce(Text(""), +)
    }
    
    static func buildArray(_ components: [Text]) -> Text {
        components.reduce(Text(""), +)
    }
    
    static func buildOptional(_ component: Text?) -> Text {
        if let component {
            return component
        }
        return Text("")
    }
    
    static func buildExpression(_ expression: Image) -> Text {
        Text(expression)
    }
    
    static func buildExpression(_ expression: Text) -> Text {
        expression
    }
    
    static func buildPartialBlock(accumulated: Text, next: Text) -> Text {
        accumulated + next
    }
    
    static func buildPartialBlock(first: Text) -> Text {
        first
    }
    
    static func buildEither(first component: Text) -> Text {
        component
    }
    
    static func buildEither(second component: Text) -> Text {
        component
    }
}
