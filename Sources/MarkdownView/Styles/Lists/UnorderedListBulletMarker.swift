/// A bullet marker for unordered list items.
public struct UnorderedListBulletMarker: MarkdownUnorderedListMarkerProtocol {
    public func marker(listDepth: Int) -> String {
        "•"
    }
}

extension MarkdownUnorderedListMarkerProtocol where Self == UnorderedListBulletMarker {
    /// A bullet marker for unordered list items.
    static public var bullet: UnorderedListBulletMarker { .init() }
}
