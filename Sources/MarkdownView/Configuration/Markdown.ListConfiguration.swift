//
//  Markdown.ListConfiguration.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import Markdown
import Foundation

struct MarkdownListConfiguration: Hashable, @unchecked Sendable {
    var leadingIndent: CGFloat = 12
    var unorderedListMarker = AnyUnorderedListMarkerProtocol(.bullet)
    var orderedListMarker = AnyOrderedListMarkerProtocol(.increasingDigits)
}

// MARK: - Ordered List Marker

public protocol OrderedListMarkerProtocol: Hashable {
    /// Returns a marker for a specific index of ordered list item. Index starting from 0.
    func marker(at index: Int) -> String
}

struct AnyOrderedListMarkerProtocol: OrderedListMarkerProtocol {
    private var _marker: AnyHashable
    
    init(_ marker: some OrderedListMarkerProtocol) {
        self._marker = AnyHashable(marker)
    }
    
    public func marker(at index: Int) -> String {
        (_marker as! (any OrderedListMarkerProtocol)).marker(at: index)
    }
}


public struct OrderedListIncreasingDigitsMarker: OrderedListMarkerProtocol {
    public func marker(at index: Int) -> String {
        String(index + 1)
    }
}

extension OrderedListMarkerProtocol where Self == OrderedListIncreasingDigitsMarker {
    static public var increasingDigits: OrderedListIncreasingDigitsMarker { .init() }
}

public struct OrderedListIncreasingLettersMarker: OrderedListMarkerProtocol {
    public func marker(at index: Int) -> String {
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
        
        return result
    }
}

extension OrderedListMarkerProtocol where Self == OrderedListIncreasingLettersMarker {
    static public var increasingLetters: OrderedListIncreasingLettersMarker { .init() }
}

// MARK: - Unordered List Marker

public protocol UnorderedListMarkerProtocol: Hashable {
    /// Returns a marker for a specific indentation level of unordered list item. indentationLevel starting from 0.
    func marker(at indentationLevel: Int) -> String
}

struct AnyUnorderedListMarkerProtocol: UnorderedListMarkerProtocol {
    private var _marker: AnyHashable
    
    init(_ marker: some UnorderedListMarkerProtocol) {
        self._marker = AnyHashable(marker)
    }
    
    public func marker(at indentationLevel: Int) -> String {
        (_marker as! (any UnorderedListMarkerProtocol)).marker(at: indentationLevel)
    }
}

public struct UnorderedListDashMarker: UnorderedListMarkerProtocol {
    public func marker(at indentationLevel: Int) -> String {
        "-"
    }
}

extension UnorderedListMarkerProtocol where Self == UnorderedListDashMarker {
    static public var dash: UnorderedListDashMarker { .init() }
}

public struct UnorderedListBulletMarker: UnorderedListMarkerProtocol {
    public func marker(at indentationLevel: Int) -> String {
        "•"
    }
}

extension UnorderedListMarkerProtocol where Self == UnorderedListBulletMarker {
    static public var bullet: UnorderedListBulletMarker { .init() }
}
