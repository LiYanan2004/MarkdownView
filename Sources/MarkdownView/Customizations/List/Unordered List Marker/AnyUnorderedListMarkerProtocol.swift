//
//  AnyUnorderedListMarkerProtocol.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/27.
//

import Foundation

public struct AnyUnorderedListMarkerProtocol: MarkdownUnorderedListMarkerProtocol {
    private var _marker: AnyHashable
    public var monospaced: Bool {
        (_marker as! (any MarkdownUnorderedListMarkerProtocol)).monospaced
    }
    
    public init<T: MarkdownUnorderedListMarkerProtocol>(_ marker: T) {
        self._marker = AnyHashable(marker)
    }
    
    public func marker(listDepth: Int) -> String {
        (_marker as! (any MarkdownUnorderedListMarkerProtocol)).marker(listDepth: listDepth)
    }
}
