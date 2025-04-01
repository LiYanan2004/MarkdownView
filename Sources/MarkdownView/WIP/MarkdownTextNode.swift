//
//  MarkdownTextNode.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/11.
//

import Foundation
import SwiftUI

@MainActor
@preconcurrency
struct MarkdownTextNode: Sendable, AllowingModifyThroughKeyPath {
    var kind: MarkdownTextKind
    var children: [MarkdownTextNode]
    var content: Content?
    var index: Int?
    var depth: Int?
    var environment: EnvironmentValues
    
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
    func render() -> Text {
        switch kind {
        case .document:
            return children
                .map { $0.render() }
                .reduce(Text(""), +)
        case .plainText:
            guard case let .text(text) = content! else {
                fatalError("Unsupported content for .plainText")
            }
            return Text(text)
        case .hardBreak:
            return BreakTextRenderer()
                .body(
                    context: BreakTextRenderer.Context(
                        node: self,
                        environment: environment
                    )
                )
        case .softBreak:
            return BreakTextRenderer()
                .body(
                    context: BreakTextRenderer.Context(
                        node: self,
                        environment: environment
                    )
                )
        case .placeholder:
            return Text(" ")
        case .paragraph:
            return ParagraphTextRenderer()
                .body(
                    context: HeadingTextRenderer.Context(
                        node: self,
                        environment: environment
                    )
                )
        case .heading:
            return HeadingTextRenderer()
                .body(
                    context: HeadingTextRenderer.Context(
                        node: self,
                        environment: environment
                    )
                )
        case .italicText, .boldText, .strikethrough:
            return FormattedTextRenderer()
                .body(
                    context: FormattedTextRenderer.Context(
                        node: self,
                        environment: environment
                    )
                )
        case .link:
            return LinkTextRenderer()
                .body(
                    context: LinkTextRenderer.Context(
                        node: self,
                        environment: environment
                    )
                )
        case .image:
            return ImageTextRenderer()
                .body(
                    context: ImageTextRenderer.Context(
                        node: self,
                        environment: environment
                    )
                )
        case .codeBlock:
            return CodeBlockTextRenderer()
                .body(
                    context: CodeBlockTextRenderer.Context(
                        node: self,
                        environment: environment
                    )
                )
        case .code:
            return InlineCodeTextRenderer()
                .body(
                    context: InlineCodeTextRenderer.Context(
                        node: self,
                        environment: environment
                    )
                )
        case .orderedList:
            return OrderedListTextRenderer()
                .body(
                    context: OrderedListTextRenderer.Context(
                        node: self,
                        environment: environment
                    )
                )
        case .unorderedList:
            return UnorderedListTextRenderer()
                .body(
                    context: UnorderedListTextRenderer.Context(
                        node: self,
                        environment: environment
                    )
                )
        case .listItem:
            return ListItemTextRenderer()
                .body(
                    context: ListItemTextRenderer.Context(
                        node: self,
                        environment: environment
                    )
                )
        default:
            return Text("Unimplemented: \(kind)")
        }
    }
}
