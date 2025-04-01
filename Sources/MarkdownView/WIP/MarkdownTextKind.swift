//
//  MarkdownTextKind.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/1.
//

import Foundation

enum MarkdownTextKind: Sendable, Hashable {
    case document
    
    case paragraph
    case heading
    case plainText
    case strikethrough
    case boldText
    case italicText
    case link
    
    case softBreak
    case hardBreak
    
    case code
    case codeBlock
    
    case orderedList
    case unorderedList
    case listItem
    
    case placeholder
    case image
    
    case unknown
}
