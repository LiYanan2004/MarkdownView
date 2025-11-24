//
//  OrderedListIncreasingLettersMarker.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/27.
//

import Foundation

/// An auto-increasing letters marker for ordered list items.
public struct OrderedListIncreasingLettersMarker: OrderedListMarkerProtocol {
    public func marker(at index: Int, listDepth: Int) -> String {
        let base = 26
        var index = index
        var result = ""
        
        // If index is smaller than 26, use single letter, otherwise, use double letters.
        if index < base {
            result = String(UnicodeScalar("a".unicodeScalars.first!.value + UInt32(index))!)
        } else {
            index -= base
            let firstLetterIndex = index / base
            let secondLetterIndex = index % base
            let firstLetter = UnicodeScalar("a".unicodeScalars.first!.value + UInt32(firstLetterIndex))!
            let secondLetter = UnicodeScalar("a".unicodeScalars.first!.value + UInt32(secondLetterIndex))!
            result.append(Character(firstLetter))
            result.append(Character(secondLetter))
        }
        
        return result + "."
    }
    
    public var monospaced: Bool { false }
}

extension OrderedListMarkerProtocol where Self == OrderedListIncreasingLettersMarker {
    /// An auto-increasing letters marker for ordered list items.
    static public var increasingLetters: OrderedListIncreasingLettersMarker { .init() }
}
