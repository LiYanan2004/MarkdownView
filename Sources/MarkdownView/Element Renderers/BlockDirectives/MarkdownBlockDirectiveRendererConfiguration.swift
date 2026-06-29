import Markdown

/// The values that describe a block directive.
@preconcurrency
@MainActor
public struct MarkdownBlockDirectiveRendererConfiguration: Sendable {
    /// The markdown source wrapped in the block directive.
    public var wrappedString: String

    /// The named arguments supplied by the block directive.
    public var arguments: [Argument]

    init(wrappedString: String, arguments: [Argument]) {
        self.wrappedString = wrappedString
        self.arguments = arguments
    }
    
    /// A named argument supplied by a block directive.
    public struct Argument {
        /// The name of the argument.
        public var name: String
        
        /// The value of that argument.
        public var value: String
        
        /// Creates an argument from a Swift Markdown directive argument.
        ///
        /// - Parameter directiveArgument: The `DirectiveArgument` of the directive block.
        init(_ directiveArgument: DirectiveArgument) {
            name = directiveArgument.name
            value = directiveArgument.value
        }
    }
}

@_documentation(visibility: internal)
@available(*, deprecated, renamed: "MarkdownBlockDirectiveRendererConfiguration")
public typealias BlockDirectiveRendererConfiguration = MarkdownBlockDirectiveRendererConfiguration
