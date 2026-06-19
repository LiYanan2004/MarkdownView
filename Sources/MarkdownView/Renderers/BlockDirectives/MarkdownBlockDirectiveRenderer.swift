import SwiftUI

/// A type that renders block directives.
///
/// Think of this type as a SwiftUI View wrapper.
///
/// Don't directly access view dependencies (e.g. `@Environment`), use a separate view instead.
@_typeEraser(AnyMarkdownBlockDirectiveRenderer)
public protocol MarkdownBlockDirectiveRenderer: MarkdownElementRenderer where Configuration == MarkdownBlockDirectiveRendererConfiguration {
    associatedtype Configuration = MarkdownBlockDirectiveRendererConfiguration
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
@available(*, deprecated, renamed: "AnyMarkdownBlockDirectiveRenderer")
public typealias AnyBlockDirectiveRenderer = AnyMarkdownBlockDirectiveRenderer
