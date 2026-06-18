/// A type that represents the marker for ordered list items.
public protocol MarkdownOrderedListMarkerProtocol: Hashable {
    /// Returns a marker for a specific index of ordered list item. Index starting from 0.
    func marker(at index: Int, listDepth: Int) -> String
    
    /// A boolean value indicates whether the marker should be monospaced, default value is `true`.
    var monospaced: Bool { get }
}

extension MarkdownOrderedListMarkerProtocol {
    public var monospaced: Bool {
        true
    }
}

@_documentation(visibility: internal)
@available(*, deprecated, renamed: "MarkdownOrderedListMarkerProtocol")
public typealias OrderedListMarkerProtocol = MarkdownOrderedListMarkerProtocol
