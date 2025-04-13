import SwiftUI

struct MarkdownNodeView: View {
    private var storage: Either<Text, AnyView>
    
    enum ContentType: String {
        case text, view
    }
    var contentType: ContentType {
        if case .left(_) = storage {
            .text
        } else if case .right(_) = storage {
            .view
        } else {
            fatalError()
        }
    }
    
    init(_ content: @autoclosure () -> Text) {
        storage = .left(content())
    }
    
    init(@ViewBuilder _ content: () -> Text) {
        storage = .left(content())
    }
    
    init<Content: View>(@ViewBuilder _ content: () -> Content) {
        storage = .right(AnyView(content()))
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
    /// Combine adjacent views of the same type.
    /// - Parameter contents: A set of contents to combine together.
    /// - Parameter alignment: The alignment in relation to these contents.
    init(
        _ contents: [MarkdownNodeView],
        alignment: HorizontalAlignment = .leading,
        autoLayout: Bool = true
    ) {
        var composedContents = [MarkdownNodeView]()
        var textStorage = TextComposer()
        for content in contents {
            if case let .left(text) = content.storage {
                textStorage.append(text)
            } else {
                if textStorage.hasText {
                    composedContents.append(MarkdownNodeView(textStorage.text))
                    textStorage = TextComposer()
                }
                composedContents.append(content)
            }
        }
        if textStorage.hasText {
            composedContents.append(MarkdownNodeView(textStorage.text))
        }
        
        // Only contains text
        if composedContents.count == 1 {
            self = composedContents[0]
        } else {
            if #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *), autoLayout {
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
