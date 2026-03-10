//
//  MarkdownViewEmitter.swift
//  MarkdownView
//
//  Created by Codex on 2026/2/6.
//

import SwiftUI
import Markdown

@MainActor
struct MarkdownViewEmitter {
    var configuration: MarkdownRendererConfiguration
    var subtreeRenderer: MarkdownSubtreeRenderer
    
    init(
        configuration: MarkdownRendererConfiguration,
        subtreeRenderer: MarkdownSubtreeRenderer
    ) {
        self.configuration = configuration
        self.subtreeRenderer = subtreeRenderer
    }
    
    func makeBody(for semanticDocument: MarkdownSemanticDocument) -> MarkdownNodeView {
        renderChildren(
            semanticDocument.rootNodes,
            layoutPolicy: .linebreak
        )
    }
    
    func makeNodeView(for semanticNode: MarkdownSemanticNode) -> MarkdownNodeView {
        render(semanticNode)
    }
}

private extension MarkdownViewEmitter {
    func render(_ semanticNode: MarkdownSemanticNode) -> MarkdownNodeView {
        switch semanticNode {
        case .document(let children):
            return renderChildren(children, layoutPolicy: .linebreak)

        case .container(let children):
            return renderChildren(children)

        case .paragraph(let children):
            return renderChildren(children)

        case .text(let plainText):
            if configuration.rendersMath {
                return InlineMathOrText(text: plainText)
                    .makeBody(configuration: configuration)
            }
            return MarkdownNodeView(plainText)

        case .blockDirective(let blockDirective):
            return MarkdownNodeView {
                MarkdownBlockDirective(blockDirective: blockDirective)
            }

        case .blockQuote(let blockQuote, _):
            return MarkdownNodeView {
                MarkdownBlockQuote(blockQuote: blockQuote)
            }

        case .softBreak:
            return MarkdownNodeView(" ")

        case .thematicBreak:
            return MarkdownNodeView {
                Divider()
            }

        case .lineBreak:
            return MarkdownNodeView("\n")

        case .inlineCode(let code):
            let tintColor = configuration.preferredTintColors[.inlineCodeBlock] ?? .accentColor
            var attributedString = AttributedString(stringLiteral: code)
            attributedString.foregroundColor = tintColor
            attributedString.backgroundColor = tintColor.opacity(0.1)
            return MarkdownNodeView(attributedString)

        case .inlineHTML(let rawHTML):
            return MarkdownNodeView(
                AttributedString(
                    rawHTML,
                    attributes: AttributeContainer().isHTML(true)
                )
            )

        case .image(let image):
            return MarkdownNodeView {
                MarkdownImage(image: image)
            }

        case .codeBlock(let codeBlock):
            return MarkdownNodeView {
                MarkdownStyledCodeBlock(
                    configuration: CodeBlockStyleConfiguration(
                        language: codeBlock.language,
                        code: codeBlock.code
                    )
                )
            }

        case .htmlBlock(let htmlBlock):
            return MarkdownNodeView {
                HTMLBlockView(html: htmlBlock.rawHTML)
            }

        case .list(let semanticList):
            return renderList(semanticList)

        case .listItem(let semanticListItem):
            return renderListItem(semanticListItem)

        case .table(let table):
            return MarkdownNodeView {
                MarkdownTable(table: table)
            }

        case .tableHead(let tableHead):
            return MarkdownNodeView {
                MarkdownTableRow(
                    rowIndex: 0,
                    cells: Array(tableHead.cells)
                )
            }

        case .tableBody(let tableBody):
            return MarkdownNodeView {
                MarkdownTableBody(tableBody: tableBody)
            }

        case .tableRow(let tableRow):
            return MarkdownNodeView {
                MarkdownTableRow(
                    rowIndex: tableRow.indexInParent + 1,
                    cells: Array(tableRow.cells)
                )
            }

        case .tableCell(let tableCell, let children):
            return renderChildren(
                children,
                alignment: tableCell.horizontalAlignment
            )

        case .heading(let heading, _):
            return MarkdownNodeView {
                HeadingText(heading: heading)
            }

        case .emphasis(let children):
            return MarkdownNodeView(
                mergeInlinePresentationIntent(
                    .emphasized,
                    children: children
                )
            )

        case .strong(let children):
            return MarkdownNodeView(
                mergeInlinePresentationIntent(
                    .stronglyEmphasized,
                    children: children
                )
            )

        case .strikethrough(let children):
            return MarkdownNodeView(
                mergeInlinePresentationIntent(
                    .strikethrough,
                    children: children
                )
            )

        case .link(let destination, _, _, let children):
            guard let destination, let destinationURL = URL(string: destination) else {
                return renderChildren(children)
            }

            let linkedContent = renderChildren(children)
            let tintColor = configuration.preferredTintColors[.link] ?? .accentColor

            if let attributedString = linkedContent.asAttributedString {
                return MarkdownNodeView(
                    attributedString.mergingAttributes(
                        AttributeContainer()
                            .link(destinationURL)
                            .foregroundColor(tintColor)
                    )
                )
            }

            return MarkdownNodeView {
                Link(destination: destinationURL) {
                    linkedContent
                }
                .foregroundStyle(tintColor)
            }
        }
    }

    func renderChildren(
        _ children: [MarkdownSemanticNode],
        alignment: HorizontalAlignment = .leading,
        layoutPolicy: MarkdownNodeView.LayoutPolicy = .adaptive
    ) -> MarkdownNodeView {
        let childViews = children.map(render)
        return MarkdownNodeView(
            childViews,
            alignment: alignment,
            layoutPolicy: layoutPolicy
        )
    }

    func mergeInlinePresentationIntent(
        _ inlinePresentationIntent: InlinePresentationIntent,
        children: [MarkdownSemanticNode]
    ) -> AttributedString {
        var mergedAttributedString = AttributedString()
        for child in children {
            guard let attributedString = render(child).asAttributedString else {
                continue
            }
            let existingIntent = attributedString.inlinePresentationIntent ?? []
            mergedAttributedString += attributedString.mergingAttributes(
                AttributeContainer()
                    .inlinePresentationIntent(existingIntent.union(inlinePresentationIntent))
            )
        }
        return mergedAttributedString
    }

    func renderList(_ semanticList: MarkdownSemanticList) -> MarkdownNodeView {
        MarkdownNodeView {
            VStack(alignment: .leading, spacing: configuration.componentSpacing) {
                ForEach(semanticList.items.indices, id: \.self) { index in
                    renderListItem(semanticList.items[index])
                }
            }
        }
    }

    func renderListItem(_ semanticListItem: MarkdownSemanticListItem) -> MarkdownNodeView {
        let leadingContent = renderChildren(semanticListItem.leadingChildren)

        return MarkdownNodeView {
            VStack(alignment: .leading, spacing: configuration.componentSpacing) {
                HStack(alignment: .firstTextBaseline) {
                    if let marker = semanticListItem.marker {
                        MarkdownSemanticListMarkerView(
                            marker: marker,
                            bodyFont: configuration.fonts[.body] ?? .body
                        )
                    }

                    if !semanticListItem.leadingChildren.isEmpty {
                        leadingContent
                    }
                }

                ForEach(semanticListItem.trailingBlocks.indices, id: \.self) { index in
                    render(semanticListItem.trailingBlocks[index])
                }
            }
            .padding(.leading, semanticListItem.indentation)
        }
    }
}

private struct MarkdownSemanticListMarkerView: View {
    var marker: MarkdownSemanticListMarker
    var bodyFont: Font

    var body: some View {
        switch marker {
        case .checkbox(let checkbox):
            switch checkbox {
            case .checked:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.tint)
            case .unchecked:
                Image(systemName: "circle")
                    .foregroundStyle(.secondary)
            }

        case .text(let value, let monospaced):
            if #available(iOS 16.4, macOS 13.3, tvOS 16.4, watchOS 9.4, *) {
                Text(value)
                    .monospaced(monospaced)
                    .font(bodyFont)
            } else {
                Text(value)
                    .font(monospaced ? bodyFont.monospaced() : bodyFont)
            }
        }
    }
}
