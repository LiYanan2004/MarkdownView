import SwiftUI
import Markdown

/// A type for rendering directive blocks.
public protocol BlockDirectiveDisplayable {
    associatedtype BlockDirectiveView: View
    
    /// Make the Directive Block View.
    /// - Parameters:
    ///   - arguments: A directive argument, parsed from the form name: value or name: "value".
    ///   - innerMarkdownView: A sub-MarkdownView inside curly braces.
    /// - Returns: A rendered block directive View.
    @ViewBuilder func makeView(
        arguments: [BlockDirectiveArgument],
        innerMarkdownView: AnyView
    ) -> BlockDirectiveView
}

struct AnyBlockDirectiveDisplayable: BlockDirectiveDisplayable {
    typealias BlockDirectiveView = AnyView

    @ViewBuilder private let displayableClosure: ([BlockDirectiveArgument], AnyView) -> AnyView

    init<D: BlockDirectiveDisplayable>(erasing blockDisplayable: D) {
        displayableClosure = { args, innerView in
            AnyView(blockDisplayable.makeView(arguments: args, innerMarkdownView: innerView))
        }
    }

    func makeView(arguments: [BlockDirectiveArgument], innerMarkdownView: AnyView) -> AnyView {
        displayableClosure(arguments, innerMarkdownView)
    }
}

/// Directive Block arguments represented from `swift-markdown/DirectiveArgument`.
public struct BlockDirectiveArgument {
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


