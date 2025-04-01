import SwiftUI
import Markdown

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
            return MarkdownMathRenderer(text: text.plainText)
                .makeBody(configuration: configuration)
        } else {
            return MarkdownNodeView {
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
//            Text(" ")
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
            StyledCodeBlock(
                configuration: CodeBlockStyleConfiguration(
                    language: codeBlock.language,
                    code: codeBlock.code
                )
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
        return MarkdownNodeView {
                MarkdownLink(link: link, configuration: configuration)
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 20) {
        ScrollView {
            Group {
                MarkdownView(#"Inline math with `$`: $ \sqrt{3x-1}+(1+x)^2 $"#)
                
                MarkdownView(#"Inline math with `\(...\)`: \(\sqrt{3x-1}+(1+x)^2\)"#)
                
                MarkdownView(#"""
        **The Cauchy-Schwarz Inequality** with `$$`
        $$ \left( \sum_{k=1}^n a_k b_k \right)^2 \leq \left( \sum_{k=1}^n a_k^2 \right) \left( \sum_{k=1}^n b_k^2 \right) $$
        """#)
                
                MarkdownView(#"""
        Sure! Here's the calculation presented in LaTeX:
        
        \[ \text{MME from MS Contin} = 60 \, \text{mg} \times 2 = 120 \, \text{mg of morphine/day} = 120 \, \text{MME} \]
        
        Certainly! Here is the calculation presented in LaTeX without any additional spaces:
        
        \[
        \text{Total MME} = \text{MME from MS Contin} + \text{MME from Percocet}
        \]
        \[\text{Total MME} = 120 \, \text{MME} + 45 \, \text{MME}\]
        \[
        \text{Total MME} = 165 \, \text{MME}
        \]
        \[
        \text{Converted to MME} = 30 \, \text{mg} \times 1.5 = 45 \, \text{MME}
        \]
        \[\text{Total MME} = 120 \, \text{MME (from MS Contin)} + 45 \, \text{MME (from Percocet)} = 165 \, \text{MME}\]
        Thus, the combined total is \( \text{165 MME} \).
        """#)
            }
        }.padding()
    }
    .markdownMathRenderingEnabled()
}
