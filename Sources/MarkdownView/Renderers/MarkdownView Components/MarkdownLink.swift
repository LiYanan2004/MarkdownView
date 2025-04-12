//
//  MarkdownLink.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/22.
//

import SwiftUI
import Markdown

struct MarkdownLink: MarkupVisitor {
    var tint: Color
    var font: Font
    
    func attributed(_ markup: Markup) -> SwiftUI.Text {
        var attributer = self
        return Text(attributer.visit(markup))
    }
    
    mutating func defaultVisit(_ markup: Markup) -> AttributedString {
        var attributedString = AttributedString()
        for child in markup.children {
            attributedString += visit(child)
        }
        return attributedString
    }
    
    func visitText(_ text: Markdown.Text) -> AttributedString {
        var attributedString = AttributedString(stringLiteral: text.plainText)
        attributedString.font = font
        return attributedString
    }
    
    mutating func visitLink(_ link: Markdown.Link) -> AttributedString {
        var attributedString = attributedString(from: link)
        if let destination = link.destination {
            attributedString.link = URL(string: destination)
        } else {
            #if os(macOS)
            attributedString.foregroundColor = .linkColor
            #elseif os(iOS)
            attributedString.foregroundColor = .link
            #elseif os(watchOS)
            attributedString.foregroundColor = .blue
            #endif
        }
        return attributedString
    }
    
    mutating func visitStrong(_ strong: Strong) -> AttributedString {
        var attributedString = attributedString(from: strong)
        attributedString.font = font.bold()
        return attributedString
    }
    
    mutating func visitEmphasis(_ emphasis: Emphasis) -> AttributedString {
        var attributedString = attributedString(from: emphasis)
        attributedString.font = font.italic()
        return attributedString
    }
    
    mutating func visitInlineCode(_ inlineCode: InlineCode) -> AttributedString {
        var attributedString = attributedString(inlineCode.code, from: inlineCode)
        attributedString.foregroundColor = tint
        attributedString.backgroundColor = tint.opacity(0.1)
        return attributedString
    }
    
    mutating func visitInlineHTML(_ inlineHTML: InlineHTML) -> AttributedString {
        var attributedString = attributedString(inlineHTML.rawHTML, from: inlineHTML)
        attributedString.font = font
        return attributedString
    }
}

extension MarkdownLink {
    mutating func attributedString(
        _ text: String = "",
        from markup: some Markup
    ) -> AttributedString {
        var attributedString = AttributedString(stringLiteral: text)
        for child in markup.children {
            attributedString += visit(child)
        }
        return attributedString
    }
}

