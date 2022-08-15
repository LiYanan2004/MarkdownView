import SwiftUI
import Markdown

/// Handle the represention of the Directive Block.
public struct MarkdownDirectiveBlockHandler {
    var content: ([Argument], any View) -> any View
    
    /// Create your own handler to represent the specific markdown syntax, which is start with `@`.
    /// - Parameter content: Your custom view with `arguments` and `Inner Wrapped Markdown View`.
    public init(@ViewBuilder content: @escaping ([Argument], any View) -> any View) {
        self.content = content
    }
    
    /// Directive Block arguments represented from `swift-markdown/DirectiveArgument`.
    public struct Argument {
        /// The name of the argument.
        public var name: String
        
        /// The value of that argument.
        public var value: String
        
        /// An argument that represented from ``Markdown/DirectiveArgument``.
        /// - Parameter directiveArgument: The `DirectiveArgument` of the directive block.
        init(_ directiveArgument: DirectiveArgument) {
            name = directiveArgument.name
            value = directiveArgument.value
        }
    }
}

extension MarkdownDirectiveBlockHandler {
    /// This is an example of how you can create your own Wrapper View.
    /// Here, type the following to create a container.
    ///
    /// ```markdown
    /// @Background(background: _, textColor: _) {
    ///     // Inner Markdown Text
    /// }
    /// ```
    ///
    /// You can create your own handler by  creating an `extension` of the `MarkdownDirectiveBlockHandler`.
    /// You will get 2 parameters for `Received Arguments` and  `Wrapped Markdown View`.
    ///
    /// - parameters
    ///     - arguments: The `Arguments` received from `()`.
    ///     - wrappedView: The `MarkdownView` represented from `{}`.
    public static var markdownWithBackground = MarkdownDirectiveBlockHandler { arguments, wrappedView in
        ViewWithBackground(arguments: arguments, wrappedView: wrappedView)
    }
}

class DirectiveBlockConfiguration {
    /// All the handlers that have been added.
    var directiveBlockHandlers: [String : MarkdownDirectiveBlockHandler] = [:]
    
    /// Add custom handler for Directive Block.
    /// - Parameters:
    ///   - handler: Represention of the Directive Block.
    ///   - name: The name of Wrapper.
    func addHandler(_ handler: MarkdownDirectiveBlockHandler, for name: String) {
        directiveBlockHandlers[name] = handler
    }
}
