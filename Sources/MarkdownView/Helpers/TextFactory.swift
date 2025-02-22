//
//  TextFactory.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/22.
//

import SwiftUI

struct TextFactory {
    private(set) var text: Text
    private(set) var hasText: Bool = false
    
    init(@TextBuilder text: @escaping () -> Text) {
        self.text = text()
    }
    
    init() {
        self.text = Text("")
    }
    
    mutating func append(_ text: Text) {
        hasText = true
        self.text = self.text + text
    }
}

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
