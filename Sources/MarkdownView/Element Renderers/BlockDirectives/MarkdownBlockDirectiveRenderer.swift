import SwiftUI

/// A type that renders block directives.
///
/// Register a block directive renderer when your markdown contains Swift Markdown block directives, such as `@Callout(title: "Important") { ... }`, and you want to replace the default child rendering with a custom SwiftUI view.
///
/// Keep environment-dependent work in a separate `View`. The renderer is a factory object, so a nested view is the correct place to read `@Environment` values or attach more MarkdownView modifiers.
///
/// The following example renders `@Callout(title: "Important") { ... }` directives and renders the directive body as markdown.
///
/// ```swift
/// struct CalloutDirectiveRenderer: MarkdownBlockDirectiveRenderer {
///     func makeBody(configuration: Configuration) -> some View {
///         CalloutDirectiveView(configuration: configuration)
///     }
/// }
///
/// private struct CalloutDirectiveView: View {
///     let configuration: MarkdownBlockDirectiveRendererConfiguration
///
///     private var title: String {
///         configuration.arguments.first { $0.name == "title" }?.value ?? "Note"
///     }
///
///     var body: some View {
///         VStack(alignment: .leading, spacing: 8) {
///             Text(title)
///                 .font(.headline)
///             MarkdownView(configuration.wrappedString)
///         }
///         .padding()
///         .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
///     }
/// }
///
/// MarkdownView(markdown)
///     .markdownElementRenderer(.blockDirective(CalloutDirectiveRenderer(), name: "Callout"))
/// ```
@_typeEraser(AnyMarkdownBlockDirectiveRenderer)
public protocol MarkdownBlockDirectiveRenderer: MarkdownElementRenderer where Configuration == MarkdownBlockDirectiveRendererConfiguration {
    associatedtype Configuration = MarkdownBlockDirectiveRendererConfiguration
}

// MARK: - Type Erasure

/// A type-erasure for type conforms to `MarkdownBlockDirectiveRenderer`.
public struct AnyMarkdownBlockDirectiveRenderer: MarkdownBlockDirectiveRenderer {
    public typealias Body = AnyView
    
    private let _makeBody: (Configuration) -> AnyView
    
    /// Creates a type-erased block directive renderer.
    ///
    /// - Parameter renderer: The renderer to erase.
    public init<T: MarkdownBlockDirectiveRenderer>(erasing renderer: T) {
        _makeBody = {
            AnyView(renderer.makeBody(configuration: $0))
        }
    }
    
    /// Creates a type-erased block directive renderer.
    ///
    /// - Parameter renderer: The renderer to erase.
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
