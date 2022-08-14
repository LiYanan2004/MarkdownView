import Markdown
import SwiftUI

extension Renderer {
    mutating func visitListItem(_ listItem: ListItem) -> AnyView {
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
    
    mutating func visitOrderedList(_ orderedList: OrderedList) -> AnyView {
        var subviews = [AnyView]()
        for (index, listItem) in orderedList.listItems.enumerated() {
            let row = HStack(alignment: .firstTextBaseline) {
                if listItem.checkbox != nil {
                    CheckBox(listItem: listItem, text: text)
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
            subviews.append(AnyView(PaddingLine()))
        }
        
        return AnyView(VStack(alignment: .leading) {
            ForEach(subviews.indices, id: \.self) { index in
                subviews[index]
            }
        })
    }
    
    mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> AnyView {
        var subviews = [AnyView]()
        for listItem in unorderedList.listItems {
            let listRow = HStack(alignment: .firstTextBaseline) {
                if listItem.checkbox != nil {
                    CheckBox(listItem: listItem, text: text)
                } else {
                    if unorderedList.listDepth == 0 {
                        SwiftUI.Text("\t•").fontWeight(.black)
                    } else {
                        SwiftUI.Text("•").fontWeight(.black)
                    }
                }
                visit(listItem)
            }
            subviews.append(AnyView(listRow))
        }
        
        if unorderedList.hasSuccessor {
            subviews.append(AnyView(PaddingLine()))
        }
        
        return AnyView(VStack(alignment: .leading) {
            ForEach(subviews.indices, id: \.self) { index in
                subviews[index]
            }
        })
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
    @Binding var text: String
    
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
        text = separatedText.joined(separator: "\n")
    }
}
