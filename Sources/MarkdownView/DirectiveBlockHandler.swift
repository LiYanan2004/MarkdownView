import SwiftUI
import Markdown

public struct MarkdownDirectiveBlockHandler {
    var content: ([Argument], any View) -> any View
    
    public init(@ViewBuilder content: @escaping ([Argument], any View) -> any View) {
        self.content = content
    }
    
    public struct Argument {
        public var name: String
        public var value: String
        
        public init(_ directiveArgument: DirectiveArgument) {
            name = directiveArgument.name
            value = directiveArgument.value
        }
    }
}

extension MarkdownDirectiveBlockHandler {
    ///
    /// This is an example of how you can create your own Wrapper View
    /// Here, type the following to create a container.
    ///
    /// ``` Swift
    /// @Background(background: _, textColor: _) {
    ///     <!-- Inner Markdown Text -->
    /// }
    /// ```
    ///
    /// You can create your own handler by  creating an `extension` of the `MarkdownDirectiveBlockHandler`
    /// You will get 2 parameters for `Received Arguments` and  `Wrapped Markdown View`
    ///
    /// - parameter arguments: The `Arguments` received from `()`
    /// - parameter wrappedView: The `MarkdownView` represented from `{}`
    ///
    public static var backgroundColor = MarkdownDirectiveBlockHandler { arguments, wrappedView in
        ViewWithBackground(arguments: arguments, wrappedView: wrappedView)
    }
}

class DirectiveBlockConfiguration {
    var directiveBlockHandlers: [String : MarkdownDirectiveBlockHandler] = [
        "background": .backgroundColor
    ]
    
    func addHandler(_ handler: MarkdownDirectiveBlockHandler, for name: String) {
        directiveBlockHandlers[name] = handler
    }
}
