import SwiftUI
import Markdown

struct Renderer: MarkupVisitor {
    typealias Result = ViewContent
    
    var text: String
    var configuration: RendererConfiguration
    // Handle text changes when toggle checkmarks.
    var interactiveEditHandler: (String) -> Void
    
    mutating func representedView(parseBlockDirectives: Bool) -> AnyView {
        let options: ParseOptions = parseBlockDirectives ? [.parseBlockDirectives] : []
        return visit(Document(parsing: text, options: options)).view
    }
    
    mutating func visitDocument(_ document: Document) -> Result {
        var contents = [Result]()
        for child in document.children {
            contents.append(visit(child))
        }
        let documentView = VStack(
            alignment: .leading, spacing: configuration.componentSpacing
        ) {
            ForEach(contents.indices, id: \.self) { index in
                contents[index].content
            }
        }
        return Result(AnyView(documentView))
    }
    
    mutating func defaultVisit(_ markup: Markdown.Markup) -> Result {
        var contents = [Result]()
        for child in markup.children {
            contents.append(visit(child))
        }
        return Result {
            ForEach(contents.indices, id: \.self) { index in
                contents[index].content
            }
        }
    }
    
    mutating func visitText(_ text: Markdown.Text) -> Result {
        Result(SwiftUI.Text(text.plainText))
    }
    
    mutating func visitParagraph(_ paragraph: Paragraph) -> Result {
        var contents = [Result]()
        var text = [SwiftUI.Text]()
        for child in paragraph.children {
            let content = visit(child)
            if content.type == .text {
                text.append(content.text)
            } else {
                if !text.isEmpty {
                    contents.append(Result(text))
                    text.removeAll()
                }
                contents.append(Result(content.view))
            }
        }
        if !text.isEmpty {
            contents.append(Result(text))
        }
        let paragraph = contents.map { AnyView($0.content) }
        return Result(paragraph)
    }

    mutating func visitLink(_ link: Markdown.Link) -> Result {
        var contents = [Result]()
        for child in link.children {
            contents.append(visit(child))
        }
        if contents.allSatisfy ({
            $0.type == .text
        }) {
            var attributer = LinkAttributer(tint: configuration.tintColor)
            let link = attributer.visit(link)
            return Result(SwiftUI.Text(link))
        } else {
            var composedContent = [Result]()
            var text = [SwiftUI.Text]()
            for content in contents {
                if content.type == .text {
                    text.append(content.text)
                } else {
                    if !text.isEmpty {
                        composedContent.append(Result(text))
                        text.removeAll()
                    }
                    composedContent.append(Result(content.content))
                }
            }
            if !text.isEmpty {
                composedContent.append(Result(text))
            }
            let link = composedContent.map { AnyView($0.content) }
            return Result(link)
        }
    }

    mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> Result {
        var contents = [Result]()
        for child in blockQuote.children {
            contents.append(visit(child))
        }
        let blockQuote = VStack(alignment: .leading, spacing: configuration.componentSpacing) {
            ForEach(contents.indices, id: \.self) { index in
                contents[index].content
            }
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.system(.body, design: .serif))
        .padding(.horizontal, 20)
        .background(.quaternary)
        .overlay(alignment: .leading) {
            Rectangle()
                .foregroundStyle(.tertiary).frame(width: 4)
        }
        .cornerRadius(3)
        
        return Result(AnyView(blockQuote))
    }

    mutating func visitImage(_ image: Markdown.Image) -> Result {
        let renderer = ImageRenderer.shared
        guard let source = URL(string: image.source ?? "") else {
            return Result(SwiftUI.Text(image.plainText))
        }

        let alt: String?
        if let title = image.title, !title.isEmpty {
            alt = title
        } else {
            alt = image.plainText.isEmpty ? nil : image.plainText
        }
        
        var handler: (any ImageDisplayable)?
        if let scheme = source.scheme {
            renderer.imageHandlers.forEach { key, value in
                if scheme.lowercased() == key.lowercased() {
                    handler = value
                    return
                }
            }
        }
        
        return Result(renderer.loadImage(handler: handler, url: source, alt: alt))
    }
}

// MARK: - Extensions

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
