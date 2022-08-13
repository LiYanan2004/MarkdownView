import SwiftUI
import Markdown

struct Renderer: MarkupVisitor {

    var configuration: RendererConfiguration
    
    mutating func RepresentedView(from doc: Document) -> AnyView {
        visit(doc)
    }
    
    mutating func visitDocument(_ document: Document) -> AnyView {
        var subviews = [AnyView]()
        
        for child in document.children {
            subviews.append(visit(child))
        }
        
        if configuration.lazyLoad {
            return AnyView(LazyVStack(alignment: .leading, spacing: 8, pinnedViews: .sectionHeaders) {
                ForEach(subviews.indices, id: \.self) { index in
                    subviews[index]
                }
            })
        } else {
            return AnyView(VStack(alignment: .leading, spacing: 8) {
                ForEach(subviews.indices, id: \.self) { index in
                    subviews[index]
                }
            })
        }
    }
    
    mutating func defaultVisit(_ markup: Markdown.Markup) -> AnyView {
        var subviews = [AnyView]()
        
        for child in markup.children {
            subviews.append(visit(child))
        }
        
        return AnyView(ForEach(subviews.indices, id: \.self) { index in
            subviews[index]
        })
    }
    
    mutating func visitText(_ text: Markdown.Text) -> AnyView {
        var subText = [SwiftUI.Text]()
        Split(text.string).forEach {
            subText.append(SwiftUI.Text($0))
        }

        return AnyView(ForEach(subText.indices, id: \.self) { index in
            subText[index]
        })
    }
    
    mutating func visitParagraph(_ paragraph: Paragraph) -> AnyView {
        var subviews = [AnyView]()
        for child in paragraph.children {
            subviews.append(visit(child))
        }
        if paragraph.hasSuccessor && !paragraph.isContainedInList {
            subviews.append(AnyView(PaddingLine()))
        }
        return AnyView(FlexibleLayout {
            ForEach(subviews.indices, id: \.self) { index in
                subviews[index]
            }
        })
    }
    
    mutating func visitLink(_ link: Markdown.Link) -> AnyView {
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

    mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> AnyView {
        var subviews = [AnyView]()
        
        for child in blockQuote.children {
            subviews.append(visit(child))
        }
        
        return AnyView(
            HStack(spacing: 0) {
                Rectangle()
                    .frame(width: 3)
                    .padding(.horizontal, 8)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading) {
                    ForEach(subviews.indices, id: \.self) { index in
                        subviews[index]
                    }
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(.body, design: .serif))
            }.fixedSize(horizontal: false, vertical: true)
        )
    }
    
    mutating func visitImage(_ image: Markdown.Image) -> AnyView {
        let configuration = configuration.imageHandlerConfiguration
        guard let source = URL(string: image.source ?? "") else {
            return AnyView(SwiftUI.Text(image.plainText))
        }
        
        let alt: String
        if let title = image.title, !title.isEmpty {
            alt = title
        } else {
            alt = image.plainText
        }
        
        var handler: String?
        configuration.imageHandlers.keys.forEach {
            if source.scheme == $0 {
                handler = $0
                return
            }
        }
        
        let ImageView: any View
        if let handler {
            // Found a specific handler.
            ImageView = configuration.imageHandlers[handler]!.image(source, alt)
        } else {
            // Didn't find a specific handler.
            // Try to load the image from the Base URL.
            ImageView = MarkdownImageHandler
                .relativePathImage(baseURL: configuration.baseURL)
                .image(source, alt)
        }
        
        return AnyView(VStack {
            AnyView(ImageView)
        })
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
