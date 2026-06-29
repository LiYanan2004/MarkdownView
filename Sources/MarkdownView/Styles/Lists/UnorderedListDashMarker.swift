/// A dash marker for unordered list items.
public struct UnorderedListDashMarker: MarkdownUnorderedListMarkerProtocol {
    public func marker(listDepth: Int) -> String {
        "-"
    }
}

extension MarkdownUnorderedListMarkerProtocol where Self == UnorderedListDashMarker {
    /// A dash marker for unordered list items.
    static public var dash: UnorderedListDashMarker { .init() }
}
