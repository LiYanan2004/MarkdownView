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
            subviews.append(AnyView(PaddingLine()))
        }
        
        return AnyView(VStack(alignment: .leading) {
            ForEach(subviews.indices, id: \.self) { index in
                subviews[index]
            }
        })
    }
}
