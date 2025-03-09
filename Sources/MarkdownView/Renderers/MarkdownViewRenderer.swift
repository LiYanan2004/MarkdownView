import SwiftUI
import Markdown
import RegexBuilder
#if canImport(Highlightr)
import Highlightr
#endif

@MainActor
struct MarkdownViewRenderer: @preconcurrency MarkupVisitor {    
    var configuration: MarkdownRenderConfiguration
    
    func render(_ markup: Markup) -> MarkdownNodeView {
        var renderer = self
        return renderer.visit(markup)
    }
    
    func visitDocument(_ document: Document) -> MarkdownNodeView {
        var nodeViews = [MarkdownNodeView]()
        for markup in document.children {
            var renderer = self
            let nodeView = renderer.visit(markup)
            if let textOnCurrentNode = nodeView.asText, nodeViews.last?.contentType == .text {
                nodeViews.append(MarkdownNodeView(Text("\n") + textOnCurrentNode))
            } else {
                nodeViews.append(nodeView)
            }
        }
        return MarkdownNodeView(nodeViews, autoLayout: false)
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
        if configuration.rendersInlineMathIfPossible {
            MarkdownMathRenderer(text: text.plainText)
                .makeBody(configuration: configuration)
        } else {
            MarkdownNodeView {
                Text(text.plainText)
            }
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
        MarkdownNodeView {
            Text(" ")
        }
    }
    
    func visitThematicBreak(_ thematicBreak: ThematicBreak) -> MarkdownNodeView {
        MarkdownNodeView {
            Divider()
        }
    }
    
    func visitLineBreak(_ lineBreak: LineBreak) -> MarkdownNodeView {
        MarkdownNodeView {
            Text("\n")
        }
    }
    
    func visitInlineCode(_ inlineCode: InlineCode) -> MarkdownNodeView {
        var attributedString = AttributedString(stringLiteral: inlineCode.code)
        attributedString.foregroundColor = configuration.inlineCodeTintColor
        attributedString.backgroundColor = configuration.inlineCodeTintColor.opacity(0.1)
        return MarkdownNodeView {
            Text(attributedString)
        }
    }
    
    func visitInlineHTML(_ inlineHTML: InlineHTML) -> MarkdownNodeView {
        MarkdownNodeView {
            Text(inlineHTML.rawHTML)
        }
    }
    
    func visitImage(_ image: Markdown.Image) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownImage(image: image)
        }
    }
    
    func visitCodeBlock(_ codeBlock: CodeBlock) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownCodeBlock(
                language: codeBlock.language,
                code: codeBlock.code
            )
        }
    }
    
    func visitHTMLBlock(_ html: HTMLBlock) -> MarkdownNodeView {
        MarkdownNodeView {
            Text(html.rawHTML)
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
            MarkdownTableHead(head: head)
        }
    }
    
    func visitTableBody(_ body: Markdown.Table.Body) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownTableBody(tableBody: body)
        }
    }
    
    func visitTableRow(_ row: Markdown.Table.Row) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownTableRow(row: row)
        }
    }
    
    func visitTableCell(_ cell: Markdown.Table.Cell) -> MarkdownNodeView {
        var cellViews = [MarkdownNodeView]()
        for child in cell.children {
            var renderer = MarkdownViewRenderer(configuration: configuration)
            let cellView = renderer.visit(child)
            cellViews.append(cellView)
        }
        return MarkdownNodeView(cellViews, alignment: cell.alignment)
    }
    
    func visitParagraph(_ paragraph: Paragraph) -> MarkdownNodeView {
        defaultVisit(paragraph)
    }
    
    func visitHeading(_ heading: Heading) -> MarkdownNodeView {
        var shouldAddAdditionalSpacing = true
        if let parent = heading.parent,
           (0..<parent.childCount).contains(heading.indexInParent - 1),
           let previousHeading = parent.child(at: heading.indexInParent - 1),
           previousHeading is Heading {
            shouldAddAdditionalSpacing = false
        }
        
        return MarkdownNodeView {
            MarkdownHeading(heading: heading, shouldAddAdditionalSpacing: shouldAddAdditionalSpacing)
        }
    }
    
    func visitEmphasis(_ emphasis: Markdown.Emphasis) -> MarkdownNodeView {
        var textStorage = TextFactory()
        for child in emphasis.children {
            var renderer = self
            guard let text = renderer.visit(child).asText else { continue }
            textStorage.append(text.italic())
        }
        return MarkdownNodeView(textStorage.text)
    }
    
    func visitStrong(_ strong: Strong) -> MarkdownNodeView {
        var textStorage = TextFactory()
        for child in strong.children {
            var renderer = self
            guard let text = renderer.visit(child).asText else { continue }
            textStorage.append(text.bold())
        }
        return MarkdownNodeView(textStorage.text)
    }
    
    func visitStrikethrough(_ strikethrough: Strikethrough) -> MarkdownNodeView {
        var textStorage = TextFactory()
        for child in strikethrough.children {
            var renderer = self
            guard let text = renderer.visit(child).asText else { continue }
            textStorage.append(text.strikethrough())
        }
        return MarkdownNodeView(textStorage.text)
    }
    
    mutating func visitLink(_ link: Markdown.Link) -> MarkdownNodeView {
        let nodeView = descendInto(link)
        switch nodeView.contentType {
        case .text:
            return MarkdownNodeView {
                MarkdownLink(link: link, configuration: configuration)
            }
        case .view:
            return nodeView
        }
    }
}
