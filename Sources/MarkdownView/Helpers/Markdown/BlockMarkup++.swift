//
//  BlockMarkup++.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/1/18.
//

import Markdown

extension BlockMarkup {
    /// The relative depth of a block markup (e.g. the nested list, the nested block quote, etc.).
    ///
    /// This value only considering the nested depth of the same block markup
    ///
    /// For example:
    ///
    /// ```
    /// - List Item 1 /* relativeDepth = 0 */
    /// - List Item 2 /* relativeDepth = 0 */
    ///   - List Item 2.1 /* relativeDepth = 1 */
    ///      - List Item 2.1.1 /* relativeDepth = 2 */
    ///
    /// > "This is a block quote" /* relativeDepth = 0 */
    /// > - List Item 1 /* relativeDepth = 0 */
    /// >   - List Item 1.1 /* relativeDepth = 1 */
    /// ```
    var relativeDepth: Int {
        let parentDepth = (parent as? Self)?.relativeDepth
        if let parentDepth {
            return parentDepth + 1
        } else {
            return 0
        }
    }
}

// MARK: - Deprecated

extension BlockQuote {
    /// Depth of the quote if nested within others. Index starts at 0.
    @available(*, deprecated, renamed: "relativeDepth")
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


extension ListItemContainer {
    @available(*, deprecated, renamed: "relativeDepth")
    var listDepth: Int {
        var index = 0

        var currentElement = parent

        while currentElement != nil {
            if currentElement is ListItemContainer {
                index += 1
            }

            currentElement = currentElement?.parent
        }
        
        return index
    }
}
