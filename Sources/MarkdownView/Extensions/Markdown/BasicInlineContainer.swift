//
//  BasicInlineContainerAlignment.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import SwiftUI
import Markdown

extension BasicInlineContainer {
    var alignment: HorizontalAlignment {
        guard parent is any TableCellContainer else { return .center }
        
        let columnIdx = self.indexInParent
        var currentElement = parent
        while currentElement != nil {
            if currentElement is Markdown.Table {
                let alignment = (currentElement as! Markdown.Table).columnAlignments[columnIdx]
                switch alignment {
                case .center: return .center
                case .left: return .leading
                case .right: return .trailing
                case .none: return .leading
                }
            }

            currentElement = currentElement?.parent
        }
        return .center
    }
}
