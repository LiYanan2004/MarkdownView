import Foundation

@_documentation(visibility: internal)
@available(*, deprecated, renamed: "HeadingLevel")
public enum MarkdownStyleTarget {
    case h1, h2, h3, h4, h5, h6
    @available(*, deprecated, message: "This style will take no effect in current release and will be removed in the future. Implement a custom `BlockQuoteStyle` instead.")
    case blockQuote
    @available(*, deprecated, message: "This style will take no effect in current release and will be removed in the future. Implement a custom `MarkdownTableStyle` instead.")
    case tableHeader, tableBody
}
