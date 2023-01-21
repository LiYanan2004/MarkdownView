import Markdown
import SwiftUI

extension Renderer {
    /// List row which contains inner items.
    mutating func visitListItem(_ listItem: ListItem) -> Result {
        var contents = [Result]()
        for child in listItem.children {
            contents.append(visit(child))
        }
        let item = AnyView(VStack(alignment: .leading, spacing: configuration.componentSpacing) {
            ForEach(contents.indices, id: \.self) { index in
                contents[index].content
            }
        })
        return Result(item)
    }
    
    mutating func visitOrderedList(_ orderedList: OrderedList) -> Result {
        var subviews = [AnyView]()
        for (index, listItem) in orderedList.listItems.enumerated() {
            let row = HStack(alignment: .firstTextBaseline) {
                if listItem.checkbox != nil {
                    CheckBox(listItem: listItem, text: text, handler: interactiveEditHandler)
                } else {
                    SwiftUI.Text("\(index + 1).")
                        .padding(.leading, orderedList.listDepth == 0 ? 12 : 0)
                }
                visit(listItem).content
            }
            subviews.append(AnyView(row))
        }
        
        let list = AnyView(VStack(alignment: .leading, spacing: configuration.componentSpacing) {
            ForEach(subviews.indices, id: \.self) { index in
                subviews[index]
            }
        })
        return Result(list)
    }
    
    mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> Result {
        var subviews = [AnyView]()
        for listItem in unorderedList.listItems {
            let listRow = HStack(alignment: .firstTextBaseline) {
                if listItem.checkbox != nil {
                    CheckBox(listItem: listItem, text: text, handler: interactiveEditHandler)
                } else {
                    SwiftUI.Text("•")
                        .font(.title2)
                        .fontWeight(.black)
                        .padding(.leading, unorderedList.listDepth == 0 ? 12 : 0)
                }
                visit(listItem).content
            }
            subviews.append(AnyView(listRow))
        }
        
        let list = AnyView(VStack(alignment: .leading, spacing: configuration.componentSpacing) {
            ForEach(subviews.indices, id: \.self) { index in
                subviews[index]
            }
        })
        return Result(list)
    }
}

struct CheckBoxRewriter: MarkupRewriter {
    func visitListItem(_ listItem: ListItem) -> Markup? {
        var listItem = listItem
        listItem.checkbox = listItem.checkbox == .checked ? .unchecked : .checked
        return listItem
    }
}

struct CheckBox: View {
    var listItem: ListItem
    var text: String
    var handler: (String) -> Void
    
    var body: some View {
        if let checkbox = listItem.checkbox {
            switch checkbox {
            case .checked:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
                    .onTapGesture(perform: toggleStatus)
            case .unchecked:
                Image(systemName: "circle")
                    .foregroundStyle(.secondary)
                    .onTapGesture(perform: toggleStatus)
            }
        }
    }
    
    func toggleStatus() {
        guard let sourceRange = listItem.range else { return }
        let rewriter = CheckBoxRewriter()
        let newNode = rewriter.visitListItem(listItem) as! ListItem
        let newMarkdownText = newNode.format().trimmingCharacters(in: .newlines)
        
        var separatedText = text.split(separator: "\n", omittingEmptySubsequences: false)
        separatedText[sourceRange.lowerBound.line - 1] = Substring(stringLiteral: newMarkdownText)
        handler(separatedText.joined(separator: "\n"))
    }
}
