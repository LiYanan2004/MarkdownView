//
//  CmarkTextContentVisitor.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/1/20.
//

#if canImport(RichText)
import SwiftUI
import Markdown
import RichText

@MainActor
@preconcurrency
@available(iOS 26, macOS 26, *)
struct CmarkTextContentVisitor: @preconcurrency MarkupVisitor {
    var configuration: MarkdownRendererConfiguration
    
    init(configuration: MarkdownRendererConfiguration) {
        self.configuration = configuration
    }
    
    func makeTextContent(for markup: any Markup) -> TextContent {
        var visitor = self
        return visitor.visit(markup)
    }
    
    func visitDocument(_ document: Document) -> TextContent {
        var renderer = self
        let contents = document.children.map {
            renderer.visit($0)
        }
        return combine(contents)
    }
    
    func defaultVisit(_ markup: Markdown.Markup) -> TextContent {
        descendInto(markup)
    }
    
    func descendInto(_ markup: any Markup) -> TextContent {
        var content = TextContent([])
        for child in markup.children {
            var renderer = self
            content += renderer.visit(child)
        }
        return content
    }
    
    func visitText(_ text: Markdown.Text) -> TextContent {
        let plainText = text.plainText
        guard configuration.rendersMath else {
            return TextContent(.string(plainText))
        }
        #if canImport(LaTeXSwiftUI)
        let mathParser = MathParser(text: plainText)
        var content = TextContent([])
        var processingIndex = plainText.startIndex
        
        for math in mathParser.mathRepresentations {
            let range = math.range
            if processingIndex < range.lowerBound {
                content += TextContent(.string(String(plainText[processingIndex..<range.lowerBound])))
            }
            
            let latexText = String(plainText[range])
            content += inlineViewContent(
                for: text,
                replacement: AttributedString(latexText)
            ) {
                InlineMath(latexText: latexText)
            }
            
            processingIndex = range.upperBound
        }
        
        if processingIndex < plainText.endIndex {
            content += TextContent(.string(String(plainText[processingIndex..<plainText.endIndex])))
        }
        
        return content
        #else
        return TextContent(.string(plainText))
        #endif
    }
    
    func visitBlockDirective(_ blockDirective: BlockDirective) -> TextContent {
        inlineViewContent(for: blockDirective, appendsLineBreak: true) {
            MarkdownBlockDirective(blockDirective: blockDirective)
        }
    }
    
    func visitBlockQuote(_ blockQuote: BlockQuote) -> TextContent {
        var visitor = self
        let children = blockQuote.blockChildren.map({ child in
            visitor.visit(child).attributedStringIgnoringViews
        })
        
        let replacementAttrString = children.reduce(AttributedString()) { attrString, row in
            return  attrString + row + "\n"
        }
        
        return inlineViewContent(
            for: blockQuote,
            replacement: replacementAttrString,
            appendsLineBreak: true
        ) {
            MarkdownBlockQuote(blockQuote: blockQuote)
        }
    }
    
    func visitSoftBreak(_ softBreak: SoftBreak) -> TextContent {
        RichText.Space(1).textContent
    }
    
    func visitThematicBreak(_ thematicBreak: ThematicBreak) -> TextContent {
        inlineViewContent(for: thematicBreak, appendsLineBreak: true) {
            Divider()
        }
    }
    
    func visitLineBreak(_ lineBreak: Markdown.LineBreak) -> TextContent {
        RichText.LineBreak(1).textContent
    }
    
    func visitInlineCode(_ inlineCode: InlineCode) -> TextContent {
        let tint = configuration.preferredTintColors[.inlineCodeBlock] ?? .accentColor
        var attributedString = AttributedString(stringLiteral: inlineCode.code)
        attributedString.foregroundColor = tint
        attributedString.backgroundColor = tint.opacity(0.1)
        return TextContent(.attributedString(attributedString))
    }
    
    func visitInlineHTML(_ inlineHTML: InlineHTML) -> TextContent {
        TextContent(
            .attributedString(
                AttributedString(
                    inlineHTML.rawHTML,
                    attributes: AttributeContainer().isHTML(true)
                )
            )
        )
    }
    
    func visitImage(_ image: Markdown.Image) -> TextContent {
        inlineViewContent(for: image) {
            MarkdownImage(image: image)
        }
    }
    
    func visitCodeBlock(_ codeBlock: CodeBlock) -> TextContent {
        inlineViewContent(
            for: codeBlock,
            replacement: AttributedString(codeBlock.code),
            appendsLineBreak: true
        ) {
            MarkdownStyledCodeBlock(
                configuration: CodeBlockStyleConfiguration(
                    language: codeBlock.language,
                    code: codeBlock.code
                )
            )
        }
    }
    
    func visitHTMLBlock(_ html: HTMLBlock) -> TextContent {
        inlineViewContent(
            for: html,
            replacement: AttributedString(
                html.rawHTML,
                attributes: AttributeContainer().isHTML(true)
            ),
            appendsLineBreak: true
        ) {
            HTMLBlockView(html: html.rawHTML)
        }
    }
    
    func visitListItem(_ listItem: ListItem) -> TextContent {
        let depth = (listItem.parent as? ListItemContainer)?.listDepth ?? 0
        let indentation = CGFloat(depth) * configuration.list.leadingIndentation
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = indentation
        paragraphStyle.firstLineHeadIndent = indentation
        
        var attributes = AttributeContainer([.paragraphStyle: paragraphStyle])
        let markerString: String?
        switch listItem.parent {
            case let list as UnorderedList:
                let marker = configuration.list.unorderedListMarker
                markerString = marker.marker(listDepth: list.listDepth)
                attributes = attributes.font((configuration.fonts[.body] ?? .body).monospaced(marker.monospaced))
            case let list as OrderedList:
                let marker = configuration.list.orderedListMarker
                markerString = marker.marker(at: listItem.indexInParent, listDepth: list.listDepth)
                attributes = attributes.font((configuration.fonts[.body] ?? .body).monospaced(marker.monospaced))
            default:
                markerString = nil
        }

        let children = Array(listItem.children)
        
        let firstChildContent = children.first.map(descendInto)
        let trailingBlocks = children.dropFirst().map { child in
            var nestedRenderer = self
            return nestedRenderer.visit(child)
        }
        
        return TextContent {
            if let markerString {
                AttributedString(markerString, attributes: attributes)
            }
            Space()
            if let firstChildContent {
                firstChildContent
            }
            LineBreak()
            
            for trailingBlock in trailingBlocks where !trailingBlock.fragments.isEmpty {
                trailingBlock
            }
        }
    }
    
    func visitOrderedList(_ orderedList: OrderedList) -> TextContent {
        var renderer = self
        let contents = orderedList.children.map { renderer.visit($0) }
        return combine(contents)
    }
    
    func visitUnorderedList(_ unorderedList: UnorderedList) -> TextContent {
        var renderer = self
        let contents = unorderedList.children.map { renderer.visit($0) }
        return combine(contents)
    }
    
    func visitTable(_ table: Markdown.Table) -> TextContent {
        var visitor = self
        let rows = ([table.head as (any TableCellContainer)] + Array(table.body.rows)).map({ row in
            Array(row.cells).reduce(AttributedString()) { attrString, cell in
                let cellAttrString = visitor.visit(cell).attributedStringIgnoringViews
                return attrString + cellAttrString + "\t"
            }
        })
        
        let replacementAttrString = rows.reduce(AttributedString()) { attrString, row in
            return attrString + row + "\n"
        }
        return inlineViewContent(
            for: table,
            replacement: replacementAttrString,
            appendsLineBreak: true
        ) {
            MarkdownTable(table: table)
        }
    }
    
    func visitHeading(_ heading: Heading) -> TextContent {
        let component = switch heading.level {
            case 1: MarkdownComponent.h1
            case 2: MarkdownComponent.h2
            case 3: MarkdownComponent.h3
            case 4: MarkdownComponent.h4
            case 5: MarkdownComponent.h5
            case 6: MarkdownComponent.h6
            default: MarkdownComponent.body
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 12
        paragraphStyle.paragraphSpacingBefore = 12
        let attributes = AttributeContainer([.paragraphStyle : paragraphStyle as NSParagraphStyle])
            .presentationIntent(.init(.header(level: heading.level), identity: heading.indexInParent))
            .accessibilityHeadingLevel(AttributeScopes.AccessibilityAttributes.HeadingLevelAttribute.HeadingLevel(rawValue: heading.level) ?? .unspecified)
            .font(configuration.fonts[component] ?? .body)
        
        return TextContent {
            AttributedString(heading.plainText, attributes: attributes)
            LineBreak()
        }
    }
    
    func visitEmphasis(_ emphasis: Markdown.Emphasis) -> TextContent {
        var attributedString = AttributedString()
        for child in emphasis.children {
            var renderer = self
            let text = renderer.visit(child).attributedStringIgnoringViews
            if text.characters.isEmpty { continue }
            let intent = text.inlinePresentationIntent ?? []
            attributedString += text.mergingAttributes(
                AttributeContainer()
                    .inlinePresentationIntent(intent.union(.emphasized))
            )
        }
        return TextContent(.attributedString(attributedString))
    }
    
    func visitStrong(_ strong: Strong) -> TextContent {
        var attributedString = AttributedString()
        for child in strong.children {
            var renderer = self
            let text = renderer.visit(child).attributedStringIgnoringViews
            if text.characters.isEmpty { continue }
            let intent = text.inlinePresentationIntent ?? []
            attributedString += text.mergingAttributes(
                AttributeContainer()
                    .inlinePresentationIntent(intent.union(.stronglyEmphasized))
            )
        }
        return TextContent(.attributedString(attributedString))
    }
    
    func visitStrikethrough(_ strikethrough: Strikethrough) -> TextContent {
        var attributedString = AttributedString()
        for child in strikethrough.children {
            var renderer = self
            let text = renderer.visit(child).attributedStringIgnoringViews
            if text.characters.isEmpty { continue }
            let intent = text.inlinePresentationIntent ?? []
            attributedString += text.mergingAttributes(
                AttributeContainer()
                    .inlinePresentationIntent(intent.union(.strikethrough))
            )
        }
        return TextContent(.attributedString(attributedString))
    }
    
    mutating func visitLink(_ link: Markdown.Link) -> TextContent {
        guard let destination = link.destination,
              let url = URL(string: destination) else {
            return descendInto(link)
        }
        
        let linkContent = descendInto(link)
        let tintColor = configuration.preferredTintColors[.link] ?? .accentColor
        
        let contentView = linkContent.fragments.first(byUnwrapping: {
            if case let .view(attachment) = $0 {
                return attachment.view
            }
            return nil
        })
        
        if let contentView {
            return inlineViewContent(
                for: link,
                replacement: AttributedString(
                    link.plainText,
                    attributes: AttributeContainer().link(url)
                )
            ) {
                Link(destination: url) {
                    contentView
                }
                .foregroundStyle(tintColor)
            }
        } else {
            let attributedString = linkContent.attributedStringIgnoringViews
            return TextContent(
                .attributedString(
                    attributedString.mergingAttributes(
                        AttributeContainer()
                            .link(url)
                            .foregroundColor(tintColor)
                    )
                )
            )
        }
    }
    
    func visitParagraph(_ paragraph: Paragraph) -> TextContent {
        TextContent {
            descendInto(paragraph)
            LineBreak()
        }
    }
}

@available(iOS 26, macOS 26, *)
private extension CmarkTextContentVisitor {
    func combine(_ contents: [TextContent]) -> TextContent {
        var combined = TextContent([])
        for content in contents where !content.fragments.isEmpty {
            combined += content
        }
        return combined
    }
    
    func inlineViewContent(
        for markup: any Markup,
        replacement: AttributedString? = nil,
        appendsLineBreak: Bool = false,
        @ViewBuilder content: @escaping () -> some View
    ) -> TextContent {
        let view = content()
            .environment(\.markdownRendererConfiguration, configuration)
        let attachment = InlineHostingAttachment(
            view,
            id: markup.range,
            replacement: replacement
        )
        return TextContent {
            TextContent(.view(attachment))
            if appendsLineBreak {
                LineBreak()
            }
        }
    }
    
}

@available(iOS 26, macOS 26, *)
fileprivate extension TextContent {
    var attributedStringIgnoringViews: AttributedString {
        fragments.reduce(AttributedString()) { attrString, frag in
            switch frag {
                case .string(let string):
                    attrString + AttributedString(string)
                case .attributedString(let value):
                    attrString + value
                case .view:
                    attrString
            }
        }
    }
}

#endif
