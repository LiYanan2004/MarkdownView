import Markdown

extension BlockQuote {
    /// Depth of the quote if nested within others. Index starts at 0.
    public var quoteDepth: Int {
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
    public var listDepth: Int {
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
