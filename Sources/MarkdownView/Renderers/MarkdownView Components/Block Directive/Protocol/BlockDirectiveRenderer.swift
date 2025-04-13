import SwiftUI
import Markdown

/// A type that  renders block directives.
@preconcurrency
@MainActor
@_typeEraser(AnyBlockDirectiveRenderer)
public protocol BlockDirectiveRenderer {
    associatedtype Body: SwiftUI.View
    
    /// Creates a view that represents the body of the block directive
    /// - Parameters:
    ///   - arguments: A directive argument, parsed from the form name: value or name: "value".
    ///   - text: Text inside the block.
    /// - Returns: A custom block view within MarkdownView.
    @preconcurrency
    @MainActor
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body
    
    typealias Configuration = BlockDirectiveRendererConfiguration
}

@preconcurrency
@MainActor
public struct BlockDirectiveRendererConfiguration: Sendable {
    public var wrappedString: String
    public var arguments: [Argument]
    public var environments: EnvironmentValues
    
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

// MARK: - Type Erasure

/// A type-erasure for type conforms to `BlockDirectiveRenderer`.
public struct AnyBlockDirectiveRenderer: BlockDirectiveRenderer {
    public typealias Body = AnyView
    
    private let _makeBody: (Configuration) -> AnyView
    
    public init<T: BlockDirectiveRenderer>(erasing renderer: T) {
        _makeBody = {
            AnyView(renderer.makeBody(configuration: $0))
        }
    }
    
    public init<T: BlockDirectiveRenderer>(_ renderer: T) {
        _makeBody = {
            AnyView(renderer.makeBody(configuration: $0))
        }
    }
    
    public func makeBody(configuration: Configuration) -> Body {
        _makeBody(configuration)
    }
}
