import Markdown
import SwiftUI

extension Renderer {
    // List row which contains inner items.
    mutating func visitListItem(_ listItem: ListItem) -> Result {
        Result {
            let contents = contents(of: listItem)
            VStack(alignment: .leading, spacing: configuration.componentSpacing) {
                ForEach(contents.indices, id: \.self) { index in
                    contents[index].content
                }
            }
        }
    }
    
    @MainActor
    mutating func visitOrderedList(_ orderedList: OrderedList) -> Result {
        Result {
            let listItems = orderedList.children.map { $0 as! ListItem }
            let itemContent = listItems.map { visit($0).content }
            let depth = orderedList.listDepth
            let rawText = text
            let configuration = configuration
            VStack(alignment: .leading, spacing: configuration.componentSpacing) {
                ForEach(listItems.indices, id: \.self) { index in
                    let listItem = listItems[index]
                    HStack(alignment: .firstTextBaseline) {
                        if listItem.checkbox != nil {
                            CheckboxView(listItem: listItem, text: rawText)
                        } else {
                            SwiftUI.Text("\(index + 1).")
                                .padding(.leading, depth == 0 ? configuration.listConfiguration.listIndent : 0)
                        }
                        itemContent[index]
                    }
                }
            }
        }
    }
    
    @MainActor
    mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> Result {
        Result {
            let listItems = unorderedList.children.map { $0 as! ListItem }
            let itemContent = listItems.map { visit($0).content }
            let depth = unorderedList.listDepth
            let rawText = text
            let configuration = configuration
            VStack(alignment: .leading, spacing: configuration.componentSpacing) {
                ForEach(itemContent.indices, id: \.self) { index in
                    let listItem = listItems[index]
                    HStack(alignment: .firstTextBaseline) {
                        if listItem.checkbox != nil {
                            CheckboxView(listItem: listItem, text: rawText)
                        } else {
                            SwiftUI.Text(configuration.listConfiguration.unorderedListBullet)
                                .font(.title2)
                                .padding(.leading, depth == 0 ? configuration.listConfiguration.listIndent : 0)
                        }
                        itemContent[index]
                    }
                }
            }
        }
    }
}

struct CheckboxView: View {
    var listItem: ListItem
    var text: String
    
    var body: some View {
        if let checkbox = listItem.checkbox {
            switch checkbox {
            case .checked:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
            case .unchecked:
                Image(systemName: "circle")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
