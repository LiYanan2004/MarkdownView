//
//  MarkdownListConfiguration.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import Foundation

package struct MarkdownListConfiguration: Hashable, @unchecked Sendable {
    package var leadingIndentation: CGFloat = 12
    package var unorderedListMarker = AnyUnorderedListMarkerProtocol(.bullet)
    package var orderedListMarker = AnyOrderedListMarkerProtocol(.increasingDigits)
}
