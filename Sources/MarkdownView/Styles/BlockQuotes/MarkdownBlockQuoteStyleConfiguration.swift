import SwiftUI

/// The properties of a block quote.
public struct MarkdownBlockQuoteStyleConfiguration {
    /// The content of a block quote.
    public var content: Content
    
    /// A type-erased content of a block quote
    public struct Content: View {
        private var content: AnyView
        @Environment(\.markdownFontGroup.blockQuote) private var font
        
        init(@ViewBuilder _ content: () -> some View) {
            self.content = AnyView(content())
        }
        
        @_documentation(visibility: internal)
        public var body: some View {
            content
                .font(font._swiftUIFont)
        }
    }
}

@available(*, unavailable)
extension MarkdownBlockQuoteStyleConfiguration: Sendable {
    
}

@_documentation(visibility: internal)
@available(*, deprecated, renamed: "MarkdownBlockQuoteStyleConfiguration")
public typealias BlockQuoteStyleConfiguration = MarkdownBlockQuoteStyleConfiguration
