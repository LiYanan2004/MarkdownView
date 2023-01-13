import SwiftUI
import Markdown

/// Handle the represention of the Directive Block.
public struct MarkdownDirectiveBlockHandler {
    var content: ([Argument], any View) -> any View

    /// Create your own handler to represent the specific markdown syntax, which is start with an `@`.
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
