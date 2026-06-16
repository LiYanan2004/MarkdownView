import SwiftUI
import Markdown

/// A type that renders block directives.
///
/// Think of this type as a SwiftUI View wrapper.
///
/// Don't directly access view dependencies (e.g. `@Environment`), use a separate view instead.
@_typeEraser(AnyMarkdownBlockDirectiveRenderer)
public protocol MarkdownBlockDirectiveRenderer: MarkdownElementRenderer where Configuration == MarkdownBlockDirectiveRendererConfiguration {
    associatedtype Configuration = MarkdownBlockDirectiveRendererConfiguration
}

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

// MARK: - Type Erasure

/// A type-erasure for type conforms to `MarkdownBlockDirectiveRenderer`.
public struct AnyMarkdownBlockDirectiveRenderer: MarkdownBlockDirectiveRenderer {
    public typealias Body = AnyView
    
    private let _makeBody: (Configuration) -> AnyView
    
    public init<T: MarkdownBlockDirectiveRenderer>(erasing renderer: T) {
        _makeBody = {
            AnyView(renderer.makeBody(configuration: $0))
        }
    }
    
    public init<T: MarkdownBlockDirectiveRenderer>(_ renderer: T) {
        _makeBody = {
            AnyView(renderer.makeBody(configuration: $0))
        }
    }
    
    public func makeBody(configuration: Configuration) -> Body {
        _makeBody(configuration)
    }
}

@_documentation(visibility: internal)
@available(*, deprecated, renamed: "MarkdownBlockDirectiveRenderer")
public typealias BlockDirectiveRenderer = MarkdownBlockDirectiveRenderer

@_documentation(visibility: internal)
@available(*, deprecated, renamed: "MarkdownBlockDirectiveRendererConfiguration")
public typealias BlockDirectiveRendererConfiguration = MarkdownBlockDirectiveRendererConfiguration

@_documentation(visibility: internal)
@available(*, deprecated, renamed: "AnyMarkdownBlockDirectiveRenderer")
public typealias AnyBlockDirectiveRenderer = AnyMarkdownBlockDirectiveRenderer
