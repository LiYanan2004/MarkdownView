//
//  CmarkNodeVisitor.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/12.
//

import SwiftUI
import Markdown

@MainActor
@preconcurrency
struct CmarkNodeVisitor: @preconcurrency MarkupVisitor {
    var configuration: MarkdownRendererConfiguration
    var elementRenderers: [MarkdownElementRendererRegistration]
    private var activeInlineIntent: InlinePresentationIntent = []

    init(
        configuration: MarkdownRendererConfiguration,
        elementRenderers: [MarkdownElementRendererRegistration]
    ) {
        self.configuration = configuration
        self.elementRenderers = elementRenderers
    }

    func makeBody(for markup: any Markup) -> some View {
        var visitor = self
        return visitor
            .visit(markup)
            .environment(\.markdownRendererConfiguration, configuration)
    }

    func visitDocument(_ document: Document) -> MarkdownNodeView {
        var visitor = self
        let nodeViews = document.children.map {
            visitor.visit($0)
        }
        return MarkdownNodeView(nodeViews, layoutPolicy: .linebreak)
    }

    func defaultVisit(_ markup: Markdown.Markup) -> MarkdownNodeView {
        descendInto(markup)
    }

    func descendInto(_ markup: any Markup) -> MarkdownNodeView {
        var nodeViews = [MarkdownNodeView]()
        for child in markup.children {
            var visitor = self
            nodeViews.append(visitor.visit(child))
        }
        return MarkdownNodeView(nodeViews)
    }

    func visitText(_ text: Markdown.Text) -> MarkdownNodeView {
        if configuration.rendersMath {
            InlineMathOrText(text: text.plainText)
                .makeBody(configuration: configuration)
        } else {
            MarkdownNodeView(text.plainText)
        }
    }

    func visitBlockDirective(_ blockDirective: BlockDirective) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownBlockDirective(blockDirective: blockDirective)
        }
    }

    func visitBlockQuote(_ blockQuote: BlockQuote) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownBlockQuote(blockQuote: blockQuote)
                .tint(configuration.preferredTintColors[.blockQuote] ?? .accentColor)
        }
    }

    func visitSoftBreak(_ softBreak: SoftBreak) -> MarkdownNodeView {
        MarkdownNodeView(" ")
    }

    func visitThematicBreak(_ thematicBreak: ThematicBreak) -> MarkdownNodeView {
        MarkdownNodeView {
            Divider()
        }
    }

    func visitLineBreak(_ lineBreak: LineBreak) -> MarkdownNodeView {
        MarkdownNodeView("\n")
    }

    func visitInlineCode(_ inlineCode: InlineCode) -> MarkdownNodeView {
        let tintColor = configuration.preferredTintColors[.inlineCodeBlock] ?? .accentColor
        var attributedString = AttributedString(stringLiteral: inlineCode.code)
        attributedString.foregroundColor = tintColor
        attributedString.backgroundColor = tintColor.opacity(0.1)
        return MarkdownNodeView(attributedString)
    }

    func visitInlineHTML(_ inlineHTML: InlineHTML) -> MarkdownNodeView {
        MarkdownNodeView(
            AttributedString(
                inlineHTML.rawHTML,
                attributes: AttributeContainer().isHTML(true)
            )
        )
    }

    func visitImage(_ image: Markdown.Image) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownImage(image: image)
        }
    }

    func visitCodeBlock(_ codeBlock: CodeBlock) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownStyledCodeBlock(
                configuration: MarkdownCodeBlockStyleConfiguration(
                    language: codeBlock.language,
                    code: codeBlock.code
                )
            )
        }
    }

    func visitHTMLBlock(_ html: HTMLBlock) -> MarkdownNodeView {
        MarkdownNodeView {
            HTMLBlockView(html: html.rawHTML)
        }
    }

    func visitListItem(_ listItem: ListItem) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownListItem(listItem: listItem)
        }
    }

    func visitOrderedList(_ orderedList: OrderedList) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownList(listItemsContainer: orderedList)
        }
    }

    func visitUnorderedList(_ unorderedList: UnorderedList) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownList(listItemsContainer: unorderedList)
        }
    }

    func visitTable(_ table: Markdown.Table) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownTable(table: table)
        }
    }

    func visitTableHead(_ head: Markdown.Table.Head) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownTableRow(
                rowIndex: 0,
                cells: Array(head.cells)
            )
        }
    }

    func visitTableBody(_ body: Markdown.Table.Body) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownTableBody(tableBody: body)
        }
    }

    func visitTableRow(_ row: Markdown.Table.Row) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownTableRow(
                rowIndex: row.indexInParent + 1 /* header */,
                cells: Array(row.cells)
            )
        }
    }

    func visitTableCell(_ cell: Markdown.Table.Cell) -> MarkdownNodeView {
        var cellViews = [MarkdownNodeView]()
        for child in cell.children {
            var visitor = self
            cellViews.append(visitor.visit(child))
        }
        return MarkdownNodeView(
            cellViews,
            alignment: cell.horizontalAlignment
        )
    }

    func visitParagraph(_ paragraph: Paragraph) -> MarkdownNodeView {
        defaultVisit(paragraph)
    }

    func visitHeading(_ heading: Heading) -> MarkdownNodeView {
        MarkdownNodeView {
            HeadingText(heading: heading)
        }
    }

    func visitEmphasis(_ emphasis: Markdown.Emphasis) -> MarkdownNodeView {
        applyInlineIntent(.emphasized, to: emphasis.children)
    }

    func visitStrong(_ strong: Strong) -> MarkdownNodeView {
        applyInlineIntent(.stronglyEmphasized, to: strong.children)
    }

    func visitStrikethrough(_ strikethrough: Strikethrough) -> MarkdownNodeView {
        applyInlineIntent(.strikethrough, to: strikethrough.children)
    }

    mutating func visitLink(_ link: Markdown.Link) -> MarkdownNodeView {
        guard let destination = link.destination,
              let url = URL(string: destination)
        else { return descendInto(link) }

        let nodeView = descendInto(link)
        let tintColor = configuration.preferredTintColors[.link] ?? .accentColor
        let underline = configuration.underlineLinks
        let availableRenderers = elementRenderers.compactMap(\.link)
        if availableRenderers.isEmpty == false,
           let urlScheme = url.scheme,
           let linkRenderer = availableRenderers.first(where: { $0.scheme == urlScheme })?.renderer {
            let labelContent: AnyView = nodeView
                .tint(tintColor)
                .erasedToAnyView()
            let linkConfiguration = MarkdownLinkRendererConfiguration(
                url: url,
                label: labelContent
            )
            return MarkdownNodeView {
                linkRenderer
                    .makeBody(configuration: linkConfiguration)
                    .erasedToAnyView()
            }
        }

        return if let attributedString = nodeView.asAttributedString {
            MarkdownNodeView(
                attributedString.mergingAttributes({
                    var container = AttributeContainer()
                        .link(url)
                        .foregroundColor(tintColor)
                    if underline {
                        container.underlineStyle = .single
                    }
                    return container
                }())
            )
        } else {
             MarkdownNodeView {
                Link(destination: url) {
                    nodeView
                }
                .foregroundStyle(tintColor)
                .underline(underline)
            }
        }
    }

    private func applyInlineIntent(
        _ newIntent: InlinePresentationIntent,
        to children: MarkupChildren
    ) -> MarkdownNodeView {
        var nodes = [MarkdownNodeView]()
        for child in children {
            var renderer = self
            renderer.activeInlineIntent.formUnion(newIntent)
            let node = renderer.visit(child)
            if let text = node.asAttributedString {
                let intent = text.inlinePresentationIntent ?? []
                let attributedNode = MarkdownNodeView(
                    text.mergingAttributes(
                        AttributeContainer().inlinePresentationIntent(intent.union(newIntent))
                    )
                )
                nodes.append(attributedNode)
            } else {
                nodes.append(node)
            }
        }
        return MarkdownNodeView(nodes)
    }
}
