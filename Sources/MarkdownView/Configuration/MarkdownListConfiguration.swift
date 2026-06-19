//
//  MarkdownListConfiguration.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import Foundation

struct MarkdownListConfiguration: Hashable, @unchecked Sendable {
    var leadingIndentation: CGFloat = 12
    var unorderedListMarker = AnyUnorderedListMarkerProtocol(.bullet)
    var orderedListMarker = AnyOrderedListMarkerProtocol(.increasingDigits)
}
