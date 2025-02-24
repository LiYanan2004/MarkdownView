//
//  MarkdownTextRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/11.
//

import Markdown
import Foundation
import CoreGraphics

struct MarkdownTextRenderer: MarkupVisitor {
    static func walkDocument(_ document: Document) -> MarkdownTextNode {
        var renderer = MarkdownTextRenderer()
        return renderer.visitDocument(document)
    }
    
    mutating func defaultVisit(_ markup: any Markdown.Markup) -> MarkdownTextNode {
        MarkdownTextNode(
            kind: .unknown,
            children: markup.children.enumerated().map {
                visit($0.element)
                    .with(\.index, $0.offset)
            }
        )
    }
    
    mutating func visitDocument(_ document: Document) -> MarkdownTextNode {
        MarkdownTextNode(
            kind: .document,
            children: document.children.enumerated().map {
                visit($0.element)
                    .with(\.index, $0.offset)
            }
        )
    }
    
    mutating func visitText(_ text: Text) -> MarkdownTextNode {
        MarkdownTextNode(
            kind: .plainText,
            children: [],
            content: .text(text.plainText)
        )
    }
    
    mutating func visitHeading(_ heading: Heading) -> MarkdownTextNode {
        MarkdownTextNode(
            kind: .heading,
            children: heading.children.enumerated().map {
                visit($0.element)
                    .with(\.index, $0.offset)
            },
            content: .heading(heading.level)
        )
    }
    
    mutating func visitStrong(_ strong: Strong) -> MarkdownTextNode {
        MarkdownTextNode(
            kind: .boldText,
            children: strong.children.enumerated().map {
                visit($0.element)
                    .with(\.index, $0.offset)
            }
        )
    }
    
    mutating func visitEmphasis(_ emphasis: Emphasis) -> MarkdownTextNode {
        MarkdownTextNode(
            kind: .italicText,
            children: emphasis.children.enumerated().map {
                visit($0.element)
                    .with(\.index, $0.offset)
            }
        )
    }
    
    mutating func visitParagraph(_ paragraph: Paragraph) -> MarkdownTextNode {
        MarkdownTextNode(
            kind: .paragraph,
            children: paragraph.children.enumerated().map {
                visit($0.element)
                    .with(\.index, $0.offset)
            }
        )
    }
    
    mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> MarkdownTextNode {
        MarkdownTextNode(
            kind: .strikethrough,
            children: strikethrough.children.enumerated().map {
                visit($0.element)
                    .with(\.index, $0.offset)
            }
        )
    }
    
    mutating func visitLink(_ link: Link) -> MarkdownTextNode {
        if let destination = link.destination, let url = URL(string: destination) {
            MarkdownTextNode(
                kind: .link,
                children: [],
                content: .link(link.title ?? link.plainText, url)
            )
        } else {
            MarkdownTextNode(
                kind: .plainText,
                children: [],
                content: .text(link.plainText)
            )
        }
    }
    
    mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> MarkdownTextNode {
        MarkdownTextNode(kind: .hardBreak, children: [])
    }
    
    mutating func visitLineBreak(_ lineBreak: LineBreak) -> MarkdownTextNode {
        MarkdownTextNode(kind: .hardBreak, children: [])
    }
    
    mutating func visitSoftBreak(_ softBreak: SoftBreak) -> MarkdownTextNode {
        MarkdownTextNode(kind: .softBreak, children: [])
    }
    
    mutating func visitInlineCode(_ inlineCode: InlineCode) -> MarkdownTextNode {
        MarkdownTextNode(
            kind: .code,
            children: [],
            content: .text(inlineCode.code)
        )
    }
    
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> MarkdownTextNode {
         if let language = codeBlock.language {
            MarkdownTextNode(
                kind: .codeBlock,
                children: [
                    MarkdownTextNode(
                        kind: .code,
                        children: [],
                        content: .text(codeBlock.code)
                    )
                ],
                content: .codeLanguage(language)
            )
        } else {
            MarkdownTextNode(
                kind: .paragraph,
                children: [
                    MarkdownTextNode(
                        kind: .plainText,
                        children: [],
                        content: .text(codeBlock.code)
                    )
                ]
            )
        }
    }
    
    mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> MarkdownTextNode {
        MarkdownTextNode(
            kind: .unorderedList,
            children: unorderedList.children.enumerated().map {
                visit($0.element)
                    .with(\.index, $0.offset)
            },
            content: nil,
            depth: unorderedList.listDepth
        )
    }
    
    mutating func visitOrderedList(_ orderedList: OrderedList) -> MarkdownTextNode {
        MarkdownTextNode(
            kind: .orderedList,
            children: orderedList.children.enumerated().map {
                visit($0.element)
                    .with(\.index, $0.offset)
            },
            content: nil,
            depth: orderedList.listDepth
        )
    }
    
    mutating func visitListItem(_ listItem: ListItem) -> MarkdownTextNode {
        if let _ = listItem.checkbox {
            MarkdownTextNode(
                kind: .listItem,
                children: listItem.children.enumerated().map {
                    visit($0.element)
                        .with(\.index, $0.offset)
                },
                content: nil
            )
        } else {
            MarkdownTextNode(
                kind: .listItem,
                children: listItem.children.enumerated().map {
                    visit($0.element)
                        .with(\.index, $0.offset)
                },
                content: nil
            )
        }
    }
    
    mutating func visitImage(_ image: Image) -> MarkdownTextNode {
        if let source = image.source, let sourceURL = URL(string: source) {
            let task = Task.detached(priority: .background) {
                (try await ImageLoader.load(sourceURL)) as (any Sendable)
            }
            return MarkdownTextNode(
                kind: .placeholder,
                children: [
                    MarkdownTextNode(
                        kind: .plainText,
                        children: [],
                        content: .text(image.title ?? image.plainText)
                    )
                ],
                content: .task(task)
            )
        } else {
            return MarkdownTextNode(
                kind: .plainText,
                children: [],
                content: .text(image.plainText)
            )
        }
    }
}
