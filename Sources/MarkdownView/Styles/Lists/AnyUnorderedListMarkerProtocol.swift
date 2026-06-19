import Foundation

struct AnyUnorderedListMarkerProtocol: MarkdownUnorderedListMarkerProtocol {
    private var _marker: AnyHashable
    var monospaced: Bool {
        (_marker as! (any MarkdownUnorderedListMarkerProtocol)).monospaced
    }
    
    init<T: MarkdownUnorderedListMarkerProtocol>(_ marker: T) {
        self._marker = AnyHashable(marker)
    }
    
    public func marker(listDepth: Int) -> String {
        (_marker as! (any MarkdownUnorderedListMarkerProtocol)).marker(listDepth: listDepth)
    }
}
