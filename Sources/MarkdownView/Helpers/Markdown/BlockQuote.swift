//
//  BlockQuote.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import Markdown

extension BlockQuote {
    /// Depth of the quote if nested within others. Index starts at 0.
    var quoteDepth: Int {
        var index = 0

        var currentElement = parent

        while currentElement != nil {
            if currentElement is BlockQuote {
                index += 1
            }

            currentElement = currentElement?.parent
        }
        
        return index
    }
}
