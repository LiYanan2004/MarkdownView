import Foundation

struct AnyOrderedListMarkerProtocol: MarkdownOrderedListMarkerProtocol {
    private var _marker: AnyHashable
    var monospaced: Bool {
        (_marker as! (any MarkdownOrderedListMarkerProtocol)).monospaced
    }
    
    init<T: MarkdownOrderedListMarkerProtocol>(_ marker: T) {
        self._marker = AnyHashable(marker)
    }
    
    public func marker(at index: Int, listDepth: Int) -> String {
        (_marker as! (any MarkdownOrderedListMarkerProtocol)).marker(at: index, listDepth: listDepth)
    }
}
