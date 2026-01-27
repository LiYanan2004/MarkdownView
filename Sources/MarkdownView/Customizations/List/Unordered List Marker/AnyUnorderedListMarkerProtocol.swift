//
//  AnyUnorderedListMarkerProtocol.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/27.
//

import Foundation

public struct AnyUnorderedListMarkerProtocol: UnorderedListMarkerProtocol {
    private var _marker: AnyHashable
    public var monospaced: Bool {
        (_marker as! (any UnorderedListMarkerProtocol)).monospaced
    }
    
    public init<T: UnorderedListMarkerProtocol>(_ marker: T) {
        self._marker = AnyHashable(marker)
    }
    
    public func marker(listDepth: Int) -> String {
        (_marker as! (any UnorderedListMarkerProtocol)).marker(listDepth: listDepth)
    }
}
