import SwiftUI
import Markdown
import NaturalLanguage

public struct MarkdownRenderer: MarkupVisitor {
    
    var imageHandlerConfiguration: ImageHandlerConfiguration
    
    mutating public func RepresentedView(from doc: Document) -> AnyView {
        visit(doc)
    }
    
    mutating public func defaultVisit(_ markup: Markdown.Markup) -> AnyView {
        var subviews = [AnyView]()
        
        for child in markup.children {
            let subview = visit(child)
            subviews.append(subview)
        }
        
        return AnyView(VStack(alignment: .leading) {
            ForEach(subviews.indices, id: \.self) { index in
                subviews[index]
            }
        })
    }
    
    mutating public func visitText(_ text: Markdown.Text) -> AnyView {
        let text = text.string
        var subText = [SwiftUI.Text]()
        
        let tagger = NLTagger(tagSchemes: [.tokenType])
        tagger.string = text
        let options = NLTagger.Options(arrayLiteral: [.omitPunctuation, .omitWhitespace])
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .tokenType, options: options) { _, tokenRange in
            let forwardTextAsArray = Array(text[tokenRange.upperBound...])
            var string = String(text[tokenRange])
            if forwardTextAsArray.isEmpty == false {
                var index = 0
                var forwardChar = forwardTextAsArray[index]
                while (forwardChar.isWhitespace || forwardChar.isPunctuation) && index < forwardTextAsArray.endIndex {
                    string.append(forwardChar)
                    index += 1
                    forwardChar = forwardTextAsArray[min(index, forwardTextAsArray.endIndex - 1)]
                }
            }
            subText.append(SwiftUI.Text(string))
            return true
        }
        
        // Fixed: Prefix whitespace or punctuation will not render as expected.
        let textAsArray = Array(text)
        var index = 0
        var forwardChar = textAsArray[index]
        var prefixText = ""
        while (forwardChar.isWhitespace || forwardChar.isPunctuation) && index < textAsArray.endIndex {
            prefixText.append(forwardChar)
            index += 1
            forwardChar = textAsArray[min(index, textAsArray.endIndex - 1)]
        }
        if prefixText.isEmpty == false {
            subText.insert(SwiftUI.Text(prefixText), at: 0)
        }

        return AnyView(ForEach(subText.indices, id: \.self) { index in
            subText[index]
        })
    }
    
    mutating public func visitEmphasis(_ emphasis: Markdown.Emphasis) -> AnyView {
        var subviews = [AnyView]()
        
        for child in emphasis.children {
            subviews.append(visit(child))
        }
        
        return AnyView(ForEach(subviews.indices, id: \.self) { index in
            subviews[index].italic()
        })
    }
    
    mutating public func visitStrong(_ strong: Strong) -> AnyView {
        var subviews = [AnyView]()
        for child in strong.children {
            subviews.append(visit(child))
        }
        return AnyView(ForEach(subviews.indices, id: \.self) { index in
            subviews[index].fontWeight(.bold)
        })
    }
    
    mutating public func visitParagraph(_ paragraph: Paragraph) -> AnyView {
        var subviews = [AnyView]()
        for child in paragraph.children {
            subviews.append(visit(child))
        }
        if paragraph.hasSuccessor && !paragraph.isContainedInList {
            subviews.append(AnyView(Newline()))
        }
        return AnyView(FlexibleLayout {
            ForEach(subviews.indices, id: \.self) { index in
                subviews[index]
            }
        })
    }
    
    mutating public func visitHeading(_ heading: Heading) -> AnyView {
        var subviews = [AnyView]()
        for child in heading.children {
            subviews.append(visit(child))
        }
        if heading.hasSuccessor {
            subviews.append(AnyView(Newline()))
        }
        let font: Font.TextStyle
        switch heading.level {
        case 1: font = .largeTitle
        case 2: font = .title
        case 3: font = .title2
        case 4: font = .title3
        case 5: font = .headline
        case 6: font = .body
        default: font = .body
        }
        return AnyView(FlexibleLayout {
            ForEach(subviews.indices, id: \.self) { index in
                subviews[index]
                    .font(.system(font, weight: .bold))
            }
        })
    }
    
    mutating public func visitLink(_ link: Markdown.Link) -> AnyView {
        var subviews = [AnyView]()
        for child in link.children {
            subviews.append(visit(child))
        }
        if let destination = URL(string: link.destination ?? "") {
            return AnyView(SwiftUI.Link(destination: destination) {
                FlexibleLayout {
                    ForEach(subviews.indices, id: \.self) { index in
                        subviews[index]
                    }
                }
            })
        } else {
            return AnyView(SwiftUI.Text(link.plainText))
        }
    }
    
    // MARK: - KNOWN ISSUE: Unexpected layout if inline code is too long.
    mutating public func visitInlineCode(_ inlineCode: InlineCode) -> AnyView {
        return AnyView(
            Text(inlineCode.code)
                .font(.system(.body, design: .monospaced))
                .scaleEffect(0.9)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 5))
        )
    }
    
    mutating public func visitCodeBlock(_ codeBlock: CodeBlock) -> AnyView {
        AnyView(VStack(alignment: .trailing, spacing: 0) {
            SwiftUI.Text(codeBlock.code)
                .font(.system(.callout, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                .overlay(alignment: .bottomTrailing) {
                    if let language = codeBlock.language {
                        SwiftUI.Text(language)
                            .font(.caption)
                            .scenePadding()
                            .foregroundStyle(.secondary)
                    }
                }
            
            Newline()
        })
    }
    
    mutating public func visitStrikethrough(_ strikethrough: Strikethrough) -> AnyView {
        var subviews = [AnyView]()
        for child in strikethrough.children {
            subviews.append(visit(child))
        }
        return AnyView(ForEach(subviews.indices, id: \.self) { index in
            subviews[index].strikethrough()
        })
    }
    
    mutating public func visitListItem(_ listItem: ListItem) -> AnyView {
        var subviews = [AnyView]()
        for child in listItem.children {
            subviews.append(visit(child))
        }
        return AnyView(VStack(alignment: .leading) {
            ForEach(subviews.indices, id: \.self) { index in
                subviews[index]
            }
        })
    }
    
    mutating public func visitOrderedList(_ orderedList: OrderedList) -> AnyView {
        var subviews = [AnyView]()
        for (index, listItem) in orderedList.listItems.enumerated() {
            let row = HStack(alignment: .firstTextBaseline) {
                if let checkbox = listItem.checkbox {
                    switch checkbox {
                    case .checked:
                        SwiftUI.Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                    case .unchecked:
                        SwiftUI.Image(systemName: "circle")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    if orderedList.listDepth == 0 {
                        SwiftUI.Text("\t\(index + 1).")
                    } else {
                        SwiftUI.Text("\(index + 1).")
                    }
                }
                visit(listItem)
            }
            subviews.append(AnyView(row))
        }
        
        if orderedList.hasSuccessor {
            subviews.append(AnyView(Newline()))
        }
        
        return AnyView(VStack(alignment: .leading) {
            ForEach(subviews.indices, id: \.self) { index in
                subviews[index]
            }
        })
    }
    
    mutating public func visitUnorderedList(_ unorderedList: UnorderedList) -> AnyView {
        var subviews = [AnyView]()
        for listItem in unorderedList.listItems {
            let listRow = HStack(alignment: .firstTextBaseline) {
                if let checkbox = listItem.checkbox {
                    switch checkbox {
                    case .checked:
                        SwiftUI.Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                    case .unchecked:
                        SwiftUI.Image(systemName: "circle")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    if unorderedList.listDepth == 0 {
                        SwiftUI.Text("\t•")
                    } else {
                        SwiftUI.Text("•")
                    }
                }
                visit(listItem)
            }
            subviews.append(AnyView(listRow))
        }
        
        if unorderedList.hasSuccessor {
            subviews.append(AnyView(Newline()))
        }
        
        return AnyView(VStack(alignment: .leading) {
            ForEach(subviews.indices, id: \.self) { index in
                subviews[index]
            }
        })
    }
    
    mutating public func visitBlockQuote(_ blockQuote: BlockQuote) -> AnyView {
        var subviews = [AnyView]()
        
        for child in blockQuote.children {
            subviews.append(visit(child))
        }
        
        return AnyView(
            VStack {
                VStack(alignment: .leading) {
                    ForEach(subviews.indices, id: \.self) { index in
                        subviews[index]
                    }
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(.body, design: .serif))
                .safeAreaInset(edge: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .frame(width: 3)
                        .padding(.horizontal, 8)
                        .foregroundStyle(.quaternary)
                }
                
                Newline()
            }
        )
    }
    
    public func visitSoftBreak(_ softBreak: SoftBreak) -> AnyView {
        AnyView(SwiftUI.Text(" "))
    }
    
    public func visitThematicBreak(_ thematicBreak: ThematicBreak) -> AnyView {
        AnyView(Divider())
    }

    public func visitLineBreak(_ lineBreak: LineBreak) -> AnyView {
        AnyView(HardBreak())
    }
    
    mutating public func visitImage(_ image: Markdown.Image) -> AnyView {
        guard let source = URL(string: image.source ?? "") else { return AnyView(SwiftUI.Text(image.plainText)) }
        
        var handler: String?
        imageHandlerConfiguration.imageHandlers.keys.forEach {
            if source.scheme == $0 {
                handler = $0
                return
            }
        }
        
        let alt: String
        if let title = image.title, !title.isEmpty {
            alt = title
        } else {
            alt = image.plainText
        }
        
        let ImageView: any View
        if let handler {
            // Found a specific handler.
            ImageView = imageHandlerConfiguration.imageHandlers[handler]!.image(source, alt)
        } else {
            // Didn't find a specific handler.
            // Try to load the image from the Base URL.
            ImageView = MarkdownImageHandler
                .relativePathImage(baseURL: imageHandlerConfiguration.baseURL)
                .image(source, alt)
        }
        
        return AnyView(VStack {
            AnyView(ImageView)
        })
    }
}

// MARK: - Extensions Land

extension ListItemContainer {
    /// Depth of the list if nested within others. Index starts at 0.
    var listDepth: Int {
        var index = 0

        var currentElement = parent

        while currentElement != nil {
            if currentElement is ListItemContainer {
                index += 1
            }

            currentElement = currentElement?.parent
        }
        
        return index
    }
}

extension BlockQuote {
    /// Depth of the quote if nested within others. Index starts at 0.
    var quoteDepth: Int {
        var index = 0

        var currentElement = parent

        while currentElement != nil {
            if currentElement is BlockQuote {
                index += 1
            }

            currentElement = currentElement?.parent
        }
        
        return index
    }
}

extension Markup {
    /// Returns true if this element has sibling elements after it.
    var hasSuccessor: Bool {
        guard let childCount = parent?.childCount else { return false }
        return indexInParent < childCount - 1
    }
    
    var isContainedInList: Bool {
        var currentElement = parent

        while currentElement != nil {
            if currentElement is ListItemContainer {
                return true
            }

            currentElement = currentElement?.parent
        }
        
        return false
    }
}

fileprivate struct Newline: View {
    var count: Int = 1
    var body: some View {
        SwiftUI.Text([String](repeating: "\n", count: count - 1).joined())
            .frame(maxWidth: .infinity)
    }
}

fileprivate struct HardBreak: View {
    var body: some View {
        Newline()
            .frame(height: 0)
    }
}
