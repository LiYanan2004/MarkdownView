//
//  AnyOrderedListMarkerProtocol.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/27.
//

import Foundation

public struct AnyOrderedListMarkerProtocol: OrderedListMarkerProtocol {
    private var _marker: AnyHashable
    public var monospaced: Bool {
        (_marker as! (any OrderedListMarkerProtocol)).monospaced
    }
    
    public init<T: OrderedListMarkerProtocol>(_ marker: T) {
        self._marker = AnyHashable(marker)
    }
    
    public func marker(at index: Int, listDepth: Int) -> String {
        (_marker as! (any OrderedListMarkerProtocol)).marker(at: index, listDepth: listDepth)
    }
}
