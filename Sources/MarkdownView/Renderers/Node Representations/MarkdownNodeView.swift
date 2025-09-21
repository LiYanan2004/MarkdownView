import SwiftUI

struct MarkdownNodeView: View {
    private var storage: Either<Text, AnyView>
    
    enum ContentType: String {
        case text, view
    }
    var contentType: ContentType {
        switch storage {
        case .left(_): .text
        case .right(_): .view
        }
    }
    
    init(_ content: @autoclosure () -> Text) {
        storage = .left(content())
    }
    
    init(@ViewBuilder _ content: () -> Text) {
        storage = .left(content())
    }
    
    init<Content: View>(@ViewBuilder _ content: () -> Content) where Content.Body == Text {
        storage = .left(content().body)
    }
    
    init<Content: View>(@ViewBuilder _ content: () -> Content) {
        let content = content()
        if let markdownNode = content as? MarkdownNodeView {
            storage = markdownNode.storage
        } else {
            storage = .right(AnyView(content))
        }
    }
    
    var body: some View {
        Group {
            if case .left(let text) = storage {
                text
            } else if case .right(let view) = storage {
                view
            }
        }
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    var asText: Text? {
        if case let .left(text) = storage {
            return text
        }
        return nil
    }
}

extension MarkdownNodeView {
    enum LayoutPolicy {
        case adaptive
        case linebreak
    }
    
    /// Combine adjacent views of the same type.
    /// - Parameter contents: A set of contents to combine together.
    /// - Parameter alignment: The alignment in relation to these contents.
    init(
        _ contents: [MarkdownNodeView],
        alignment: HorizontalAlignment = .leading,
        layoutPolicy: LayoutPolicy = .adaptive
    ) {
        var composedContents = [MarkdownNodeView]()
        var styledTexts: [SwiftUI.Text] = []
        for content in contents {
            if case let .left(text) = content.storage {
                if layoutPolicy == .linebreak && !styledTexts.isEmpty {
                    styledTexts.append(SwiftUI.Text(verbatim: "\n"))
                }
                styledTexts.append(text)
            } else {
                if !styledTexts.isEmpty {
                    composedContents.append(MarkdownNodeView {
                        styledTexts.reduce(SwiftUI.Text(""), +)
                    })
                    styledTexts = []
                }
                composedContents.append(content)
            }
        }
        if !styledTexts.isEmpty {
            composedContents.append(MarkdownNodeView {
                styledTexts.reduce(SwiftUI.Text(""), +)
            })
        }
        
        if composedContents.count == 1 {
            if let textOnly = composedContents[0].asText {
                storage = .left(textOnly)
            } else {
                storage = .right(AnyView(composedContents[0].body))
            }
        } else {
            if layoutPolicy == .adaptive,
               #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *) {
                let composedView = FlowLayout(verticleSpacing: 8) {
                    ForEach(composedContents.indices, id: \.self) {
                        composedContents[$0].body
                    }
                }
                storage = .right(AnyView(composedView))
            } else {
                let composedView = VStack(alignment: alignment, spacing: 8) {
                    ForEach(composedContents.indices, id: \.self) {
                        composedContents[$0].body
                    }
                }
                storage = .right(AnyView(composedView))
            }
        }
    }
}
