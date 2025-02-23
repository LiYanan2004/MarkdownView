//
//  MarkdownTextNode.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/11.
//

import Foundation
import SwiftUI

struct MarkdownTextNode: Sendable, AllowingModifyThroughKeyPath {
    var kind: MarkdownTextKind
    var children: [MarkdownTextNode]
    var content: Content?
    var index: Int?
    var depth: Int?
    
    enum Content: Sendable {
        case text(String)
        case heading(Int)
        case codeLanguage(String)
        case link(String, URL)
        case image(Image)
        case task(Task<Sendable, Error>)
    }
    
    mutating func modifyOverIteration(_ body: (inout Self) async throws -> Void) async rethrows {
        try await body(&self)
        for index in children.indices {
            try await children[index].modifyOverIteration(body)
        }
    }
}

extension MarkdownTextNode {
    func render(configuration: MarkdownRenderConfiguration) -> Text {
        switch kind {
        case .document:
            return children
                .map { $0.render(configuration: configuration) }
                .reduce(Text(""), +)
        case .plainText:
            guard case let .text(text) = content! else {
                fatalError("Unsupported content for .plainText")
            }
            return Text(text)
        case .hardBreak:
            return BreakTextRenderer()
                .body(context: BreakTextRenderer.Context(node: self, renderConfiguration: configuration))
        case .softBreak:
            return BreakTextRenderer()
                .body(context: BreakTextRenderer.Context(node: self, renderConfiguration: configuration))
        case .placeholder:
            return Text(" ")
        case .paragraph:
            return ParagraphTextRenderer()
                .body(context: HeadingTextRenderer.Context(node: self, renderConfiguration: configuration))
        case .heading:
            return HeadingTextRenderer()
                .body(context: HeadingTextRenderer.Context(node: self, renderConfiguration: configuration))
        case .italicText, .boldText, .strikethrough:
            return FormattedTextRenderer()
                .body(context: FormattedTextRenderer.Context(node: self, renderConfiguration: configuration))
        case .link:
            return LinkTextRenderer()
                .body(context: LinkTextRenderer.Context(node: self, renderConfiguration: configuration))
        case .image:
            return ImageTextRenderer()
                .body(context: ImageTextRenderer.Context(node: self, renderConfiguration: configuration))
            
        case .codeBlock:
            return CodeBlockTextRenderer()
                .body(context: CodeBlockTextRenderer.Context(node: self, renderConfiguration: configuration))
        case .code:
            return InlineCodeTextRenderer()
                .body(context: InlineCodeTextRenderer.Context(node: self, renderConfiguration: configuration))
            
        case .orderedList:
            return OrderedListTextRenderer()
                .body(context: OrderedListTextRenderer.Context(node: self, renderConfiguration: configuration))
        case .unorderedList:
            return UnorderedListTextRenderer()
                .body(context: UnorderedListTextRenderer.Context(node: self, renderConfiguration: configuration))
        case .listItem:
            return ListItemTextRenderer()
                .body(context: ListItemTextRenderer.Context(node: self, renderConfiguration: configuration))
            
        default:
            return Text("Unimplemented: \(kind)")
        }
    }
}

enum MarkdownTextKind: Sendable, Equatable {
    case document
    
    case paragraph
    case heading
    case plainText
    case strikethrough
    case boldText
    case italicText
    case link
    
    case softBreak
    case hardBreak
    
    case code
    case codeBlock
    
    case orderedList
    case unorderedList
    case listItem
    
    case placeholder
    case image
    
    case unknown
}
