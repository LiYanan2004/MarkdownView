import Markdown

extension OrderedList {
    /// The index to pass to ``MarkdownOrderedListMarkerProtocol/marker(at:listDepth:)``
    /// for the item at `index`, offset by the number the list starts at in the source.
    ///
    /// A list that starts at `3.` -- for example one that continues a list from an earlier
    /// message, or one split from its predecessor by an unindented paragraph -- keeps
    /// rendering `3.`, `4.`, … instead of restarting at `1.`.
    func markerIndex(forItemAt index: Int) -> Int {
        Int(startIndex) - 1 + index
    }
}
