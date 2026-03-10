import SwiftUI
import Markdown

struct MarkdownList<List: ListItemContainer>: View {
    var listItemsContainer: List
    private var depth: Int {
        listItemsContainer.listDepth
    }
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    private var marker: Either<AnyUnorderedListMarkerProtocol, AnyOrderedListMarkerProtocol> {
        if listItemsContainer is UnorderedList {
            return .left(configuration.list.unorderedListMarker)
        } else if listItemsContainer is OrderedList {
            return .right(configuration.list.orderedListMarker)
        } else {
            fatalError("Marker Protocol not implemented for \(type(of: listItemsContainer)).")
        }
    }
    
    private var listItems: [ListItem] {
        Array(listItemsContainer.listItems)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: configuration.componentSpacing) {
            ForEach(listItems.indices, id: \.self) { index in
                HStack(alignment: .firstTextBaseline) {
                    CheckboxOrMarker(list: self, listItem: listItems[index], index: index)
                        .padding(.leading, depth == 0 ? configuration.list.leadingIndentation : 0)
                    CmarkNodeVisitor(configuration: configuration)
                        .makeBody(for: listItems[index])
                }
            }
        }
    }
    
    struct CheckboxOrMarker: View {
        var list: MarkdownList<List>
        var listItem: ListItem
        var index: Int
        
        var body: some View {
            if let checkBox = listItem.checkbox {
                MarkdownCheckbox(checkbox: checkBox)
            } else if case let .left(unorderedMarker) = list.marker {
                SwiftUI.Text(unorderedMarker.marker(listDepth: list.depth))
                    .backdeployedMonospaced(unorderedMarker.monospaced)
            } else if case let .right(orderedMarker) = list.marker {
                SwiftUI.Text(orderedMarker.marker(at: index, listDepth: list.depth))
                    .backdeployedMonospaced(orderedMarker.monospaced)
            }
        }
    }
    
    private struct MarkdownCheckbox: View {
        var checkbox: Checkbox
        
        var body: some View {
            switch checkbox {
            case .checked:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.tint)
            case .unchecked:
                Image(systemName: "circle")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct MarkdownListItem: View {
    var listItem: ListItem
    @Environment(\.markdownRendererConfiguration) private var configuration

    private var children: [Markup] {
        Array(listItem.children)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: configuration.componentSpacing) {
            ForEach(children.indices, id: \.self) { index in
                CmarkNodeVisitor(configuration: configuration)
                    .makeBody(for: children[index])
            }
        }
    }
}

// MARK: - Auxiliary

fileprivate extension SwiftUI.Text {
    func backdeployedMonospaced(_ isActive: Bool = true) -> SwiftUI.Text {
        if #available(iOS 16.4, macOS 13.3, tvOS 16.4, watchOS 9.4, *) {
            return monospaced(isActive)
        } else {
            @Environment(\.font) var font
            return self.font(font?.monospaced())
        }
    }
}
