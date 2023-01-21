import SwiftUI

struct ViewContent {
    var id = UUID()
    var text: Text
    var view: AnyView
    var type: ContentType
    
    enum ContentType: String {
        case text, view
    }
    
    @ViewBuilder var content: some View {
        switch self.type {
        case .text: self.text
        case .view: self.view
        }
    }
    
    init(_ content: Text) {
        text = content
        view = AnyView(EmptyView())
        type = .text
    }
    
    init(_ content: some View) {
        text = Text("")
        view = AnyView(content)
        type = .view
    }
}

// MARK: Initialize with SwiftUI Text
extension ViewContent {
    init(_ multiText: [Text]) {
        type = .text
        view = AnyView(EmptyView())
        self.text = Text(verbatim: "")
        for partialText in multiText {
            self.text = self.text + partialText
        }
    }
}

// MARK: Initialize with Views
extension ViewContent {
    init(_ contents: [AnyView]) {
        text = Text("")
        type = .view
        if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
            let composedView = FlowLayout(verticleSpacing: 10) {
                ForEach(contents.indices, id: \.self) {
                    contents[$0]
                }
            }
            view = AnyView(composedView)
        } else {
            let composedView = ForEach(contents.indices, id: \.self) {
                contents[$0]
            }
            view = AnyView(composedView)
        }
    }
}
