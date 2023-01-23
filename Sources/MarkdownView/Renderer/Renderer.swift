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
        Result {
            let contents = contents(of: document)
            VStack(alignment: .leading, spacing: configuration.componentSpacing) {
                ForEach(contents.indices, id: \.self) { index in
                    contents[index].content
                }
            }
        }
    }
    
    mutating func defaultVisit(_ markup: Markdown.Markup) -> Result {
        Result(contents(of: markup))
    }
    
    mutating func visitText(_ text: Markdown.Text) -> Result {
        Result(SwiftUI.Text(text.plainText))
    }
    
    mutating func visitParagraph(_ paragraph: Paragraph) -> Result {
        Result(contents(of: paragraph))
    }

    mutating func visitLink(_ link: Markdown.Link) -> Result {
        var contents = [Result]()
        var isText = true
        for child in link.children {
            let content = visit(child)
            contents.append(content)
            if content.type == .view {
                isText = false
            }
        }
        if isText {
            var attributer = LinkAttributer(tint: configuration.tintColor)
            let link = attributer.visit(link)
            return Result(SwiftUI.Text(link))
        } else {
            return Result(contents)
        }
    }

    mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> Result {
        Result {
            let contents = contents(of: blockQuote)
            VStack(alignment: .leading, spacing: configuration.componentSpacing) {
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
        }
    }

    mutating func visitImage(_ image: Markdown.Image) -> Result {
        let renderer = ImageRenderer.shared
        guard let source = URL(string: image.source ?? "") else {
            return Result(SwiftUI.Text(image.plainText))
        }

        let alt: String?
        if !(image.parent is Markdown.Link) {
            if let title = image.title, !title.isEmpty {
                alt = title
            } else {
                alt = image.plainText.isEmpty ? nil : image.plainText
            }
        } else {
            // If the image is inside a link, then ignore the alternative text
            alt = nil
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

extension Renderer {
    mutating func contents(of markup: Markup) -> [Result] {
        markup.children.map { visit($0) }
    }
}
