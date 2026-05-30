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

    /// Inline emphasis (bold / italic / strikethrough) inherited from ancestor
    /// nodes. Threaded down the visit so leaf producers that build their own
    /// label — notably a link rendered by a custom `MarkdownLinkRenderer`, whose
    /// output is a SwiftUI View that can't be re-styled by an ancestor — can
    /// apply the emphasis when constructing their attributed text. Text nodes
    /// don't need it (the ancestor merges the intent onto their runs directly).
    var activeInlineIntent: InlinePresentationIntent = []

    init(configuration: MarkdownRendererConfiguration) {
        self.configuration = configuration
    }
    
    func makeBody(for markup: any Markup) -> some View {
        var visitor = self
        return visitor
            .visit(markup)
            .environment(\.markdownRendererConfiguration, configuration)
    }

    func visitDocument(_ document: Document) -> MarkdownNodeView {
        var renderer = self
        let nodeViews = document.children.map {
            renderer.visit($0)
        }
        return MarkdownNodeView(nodeViews, layoutPolicy: .linebreak)
    }
    
    func defaultVisit(_ markup: Markdown.Markup) -> MarkdownNodeView {
        descendInto(markup)
    }
    
    func descendInto(_ markup: any Markup) -> MarkdownNodeView {
        var nodeViews = [MarkdownNodeView]()
        for child in markup.children {
            var renderer = self
            let nodeView = renderer.visit(child)
            nodeViews.append(nodeView)
        }
        return MarkdownNodeView(nodeViews)
    }
    
    func visitText(_ text: Markdown.Text) -> MarkdownNodeView {
        if configuration.math.shouldRender {
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
        var attributedString = AttributedString(stringLiteral: inlineCode.code)
        attributedString.foregroundColor = configuration.inlineCodeTintColor
        attributedString.backgroundColor = configuration.inlineCodeTintColor.opacity(0.1)
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
                configuration: CodeBlockStyleConfiguration(
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
            var renderer = CmarkNodeVisitor(configuration: configuration)
            let cellView = renderer.visit(child)
            cellViews.append(cellView)
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
            MarkdownHeading(heading: heading)
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

    /// Merge an inline presentation intent (bold / italic / strikethrough) onto
    /// a run of inline children. Text children receive the intent on their
    /// attributed runs. Non-text children — e.g. a link rendered by a custom
    /// `MarkdownLinkRenderer`, which returns a SwiftUI View that cannot carry an
    /// `InlinePresentationIntent` — are preserved as-is rather than dropped, and
    /// laid out alongside the text by `MarkdownNodeView`'s text+view compositor.
    /// (Previously these children were silently skipped, so e.g. a link inside
    /// `**bold**` disappeared entirely.)
    private func applyInlineIntent(
        _ newIntent: InlinePresentationIntent,
        to children: MarkupChildren
    ) -> MarkdownNodeView {
        var nodes = [MarkdownNodeView]()
        for child in children {
            var renderer = self
            // Thread the emphasis down so view-producing descendants (e.g. a
            // custom-rendered link) can bold/italicize their own label.
            renderer.activeInlineIntent.formUnion(newIntent)
            let node = renderer.visit(child)
            if let text = node.asAttributedString {
                let intent = text.inlinePresentationIntent ?? []
                nodes.append(MarkdownNodeView(
                    text.mergingAttributes(
                        AttributeContainer().inlinePresentationIntent(intent.union(newIntent))
                    )
                ))
            } else {
                nodes.append(node)
            }
        }
        return MarkdownNodeView(nodes)
    }
    
    mutating func visitLink(_ link: Markdown.Link) -> MarkdownNodeView {
        guard let destination = link.destination,
              let url = URL(string: destination)
        else { return descendInto(link) }

        let nodeView = descendInto(link)

        // Custom renderer dispatch (Orbit fork addition).
        // Build defaultLabel by routing back through MarkdownNodeView so we
        // preserve _MarkdownText's async HTML-run processing (isHTML(true)
        // runs set by visitInlineHTML are converted via NSAttributedString
        // HTML import in _MarkdownText.swift). Use mergingAttributes
        // (default .keepNew) for color so it OVERRIDES any per-run
        // foreground (e.g. visitInlineCode sets inlineCodeTintColor
        // explicitly) — matches Branch A semantics below.
        if let scheme = url.scheme,
           let renderer = configuration.linkRenderers[scheme] ?? configuration.linkRenderers["*"]
        {
            let defaultLabel: AnyView
            if let attrs = nodeView.asAttributedString {
                defaultLabel = AnyView(
                    MarkdownNodeView(
                        attrs.mergingAttributes(
                            AttributeContainer()
                                .foregroundColor(configuration.linkTintColor)
                        )
                    )
                )
            } else {
                defaultLabel = AnyView(
                    nodeView.foregroundStyle(configuration.linkTintColor)
                )
            }
            // Pass inherited emphasis (link inside **bold** / *italic* /
            // ~~strike~~) to the renderer. The renderer owns its label's font,
            // so it (not the library) reflects the emphasis — an
            // `inlinePresentationIntent` attribute or `.bold()` on the label
            // doesn't reliably render through a custom renderer's view, and a
            // custom font's bold face must be selected explicitly.
            let config = MarkdownLinkRendererConfiguration(
                url: url,
                label: defaultLabel,
                inlinePresentationIntent: activeInlineIntent
            )
            // `renderer.makeBody` is the stored closure on
            // `AnyMarkdownLinkRenderer` and already returns `AnyView` — no
            // explicit `.erasedToAnyView()` needed.
            return MarkdownNodeView {
                renderer.makeBody(config)
            }
        }

        // Default path — UNCHANGED for text-only links (Branch A).
        // Note: we intentionally do NOT add .help() to Branch A.
        // _MarkdownText wraps the whole paragraph in a single
        // Text(AttributedString); a .help() there would apply to the entire
        // paragraph, not per link. Per-link tooltips are only achievable
        // via the custom-renderer path above (each link becomes its own
        // View).
        return if let attributedString = nodeView.asAttributedString {
            MarkdownNodeView(
                attributedString.mergingAttributes(
                    AttributeContainer()
                        .link(url)
                        .foregroundColor(configuration.linkTintColor)
                )
            )
        } else {
             MarkdownNodeView {
                Link(destination: url) {
                    nodeView
                }
                .foregroundStyle(configuration.linkTintColor)
                .help(url.absoluteString)
            }
        }
    }
}
