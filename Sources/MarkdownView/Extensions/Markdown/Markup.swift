//
//  Markup.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import Markdown

extension Markup {
    var hasSuccessor: Bool {
        guard let childCount = parent?.childCount else { return false }
        return indexInParent < childCount - 1
    }

    var isContainedInList: Bool {
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

// MARK: - Content-Based Hashing for Stable View Identity

extension Markup {
    /// A stable hash based on the content and structure of this markup node.
    /// This hash remains consistent across re-parses if the content is unchanged.
    /// Complexity: O(1) for most nodes, O(n) for nodes with many children
    var stableContentHash: Int {
        var hasher = Hasher()

        // Hash node type
        hasher.combine(String(describing: type(of: self)))

        // Hash node-specific attributes and content
        hashNodeSpecificContent(into: &hasher)

        // Hash structural information
        hasher.combine(childCount)

        // For text-based nodes, hash the content
        if let text = self as? Text {
            hasher.combine(text.string)
        } else if let inlineCode = self as? InlineCode {
            hasher.combine(inlineCode.code)
        } else if let codeBlock = self as? CodeBlock {
            hasher.combine(codeBlock.code)
        }

        // Recursively hash children for container nodes
        if childCount > 0 {
            for child in children {
                hasher.combine(child.stableContentHash)
            }
        }

        return hasher.finalize()
    }

    /// Hash node-specific attributes (heading level, code language, etc.)
    private func hashNodeSpecificContent(into hasher: inout Hasher) {
        switch self {
        case let heading as Heading:
            hasher.combine("heading")
            hasher.combine(heading.level)

        case let codeBlock as CodeBlock:
            hasher.combine("codeBlock")
            hasher.combine(codeBlock.language ?? "")

        case let link as Link:
            hasher.combine("link")
            hasher.combine(link.destination ?? "")

        case let image as Image:
            hasher.combine("image")
            hasher.combine(image.source ?? "")
            hasher.combine(image.title ?? "")

        case let htmlBlock as HTMLBlock:
            hasher.combine("htmlBlock")
            hasher.combine(htmlBlock.rawHTML)

        case let inlineHTML as InlineHTML:
            hasher.combine("inlineHTML")
            hasher.combine(inlineHTML.rawHTML)

        case is OrderedList:
            hasher.combine("orderedList")

        case is UnorderedList:
            hasher.combine("unorderedList")

        case is ListItem:
            hasher.combine("listItem")

        case is BlockQuote:
            hasher.combine("blockQuote")

        case is Paragraph:
            hasher.combine("paragraph")

        case is Text:
            hasher.combine("text")

        case is Emphasis:
            hasher.combine("emphasis")

        case is Strong:
            hasher.combine("strong")

        case is ThematicBreak:
            hasher.combine("thematicBreak")

        case is SoftBreak:
            hasher.combine("softBreak")

        case is LineBreak:
            hasher.combine("lineBreak")

        case is InlineCode:
            hasher.combine("inlineCode")

        case is Strikethrough:
            hasher.combine("strikethrough")

        case is Table:
            hasher.combine("table")

        case is Table.Head:
            hasher.combine("tableHead")

        case is Table.Body:
            hasher.combine("tableBody")

        case is Table.Row:
            hasher.combine("tableRow")

        case is Table.Cell:
            hasher.combine("tableCell")

        default:
            // Fallback for custom or future node types
            hasher.combine("unknown")
        }
    }
}

// MARK: - Structural Comparison

extension Markup {
    /// Checks if two markup nodes have the same structure and content.
    /// This is a fast approximation using content hashing.
    /// For deep structural equality, use swift-markdown's built-in `hasSameStructure(as:)`
    func hasSameContentHash(as other: Markup) -> Bool {
        return self.stableContentHash == other.stableContentHash
    }
}
