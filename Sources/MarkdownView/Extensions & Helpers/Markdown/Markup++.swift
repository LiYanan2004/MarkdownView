import Markdown

extension Markup {
    public var hasSuccessor: Bool {
        guard let childCount = parent?.childCount else { return false }
        return indexInParent < childCount - 1
    }

    public var isContainedInList: Bool {
        var currentElement = parent

        while currentElement != nil {
            if currentElement is ListItemContainer {
                return true
            }

            currentElement = currentElement?.parent
        }

        return false
    }
}

// TODO: Remove these when swift-markdown adapts all relevant types for Swift 6.
extension Markdown.Document: @retroactive @unchecked Sendable { }
extension Markdown.Table: @retroactive @unchecked Sendable { }
extension Markdown.Table.Row: @retroactive @unchecked Sendable { }
extension Markdown.OrderedList: @retroactive @unchecked Sendable { }
extension Markdown.UnorderedList: @retroactive @unchecked Sendable { }
extension Markdown.Heading: @retroactive @unchecked Sendable { }
