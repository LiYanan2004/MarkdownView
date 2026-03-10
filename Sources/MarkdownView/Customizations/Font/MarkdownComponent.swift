import Foundation

@_documentation(visibility: internal)
public enum MarkdownComponent: Hashable, Sendable, CaseIterable {
    case h1
    case h2
    case h3
    case h4
    case h5
    case h6
    case body
    case codeBlock
    case blockQuote
    case tableHeader
    case tableBody
    case inlineMath
    case displayMath
}
