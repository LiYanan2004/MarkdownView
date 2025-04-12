import SwiftUI
import Markdown

/// A type that  renders block directives.
@preconcurrency
@MainActor
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

public struct BlockDirectiveRendererConfiguration: Sendable, Hashable {
    public var text: String
    public var arguments: [Argument]
    
    /// Directive Block arguments represented from `swift-markdown/DirectiveArgument`.
    public struct Argument: Sendable, Hashable {
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
    
    @ViewBuilder private let _makeBody: (Configuration) -> AnyView
    
    init<D: BlockDirectiveRenderer>(erasing blockDisplayable: D) {
        _makeBody = {
            AnyView(blockDisplayable.makeBody(configuration: $0))
        }
    }
    
    public func makeBody(configuration: Configuration) -> Body {
        _makeBody(configuration)
    }
}
