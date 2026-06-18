import Markdown

/// The properties of a block directive.
@preconcurrency
@MainActor
public struct MarkdownBlockDirectiveRendererConfiguration: Sendable {
    /// The string wrapped in a block directive.
    public var wrappedString: String
    /// The arguments of a block directive.
    public var arguments: [Argument]

    package init(wrappedString: String, arguments: [Argument]) {
        self.wrappedString = wrappedString
        self.arguments = arguments
    }
    
    /// Directive Block arguments represented from `swift-markdown/DirectiveArgument`.
    public struct Argument {
        /// The name of the argument.
        public var name: String
        
        /// The value of that argument.
        public var value: String
        
        /// An argument that represented from ``Markdown/DirectiveArgument``.
        /// - Parameter directiveArgument: The `DirectiveArgument` of the directive block.
        package init(_ directiveArgument: DirectiveArgument) {
            name = directiveArgument.name
            value = directiveArgument.value
        }
    }
}

@_documentation(visibility: internal)
@available(*, deprecated, renamed: "MarkdownBlockDirectiveRendererConfiguration")
public typealias BlockDirectiveRendererConfiguration = MarkdownBlockDirectiveRendererConfiguration
