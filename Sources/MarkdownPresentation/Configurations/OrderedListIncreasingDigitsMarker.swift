/// An auto-increasing digits marker for ordered list items.
public struct OrderedListIncreasingDigitsMarker: MarkdownOrderedListMarkerProtocol {
    public func marker(at index: Int, listDepth: Int) -> String {
        String(index + 1) + "."
    }
    
    public var monospaced: Bool { false }
}

extension MarkdownOrderedListMarkerProtocol where Self == OrderedListIncreasingDigitsMarker {
    /// An auto-increasing digits marker for ordered list items.
    static public var increasingDigits: OrderedListIncreasingDigitsMarker { .init() }
}
