//
//  MarkdownTextInlineViewIdentifier.swift
//  MarkdownView
//
//  Created by Codex on 2026/6/21.
//

import Markdown

struct MarkdownTextInlineViewIdentifier: Hashable {
    enum Role: Hashable {
        case blockAttachment
        case customLink
        case inlineMath(occurrence: Int)
        case listCheckbox
        case thematicBreak
    }

    private let markupTreePath: [Int]
    private let role: Role

    init(markup: any Markup, role: Role) {
        var markupTreePath: [Int] = []
        var currentMarkup: (any Markup)? = markup

        while let markup = currentMarkup, let parent = markup.parent {
            markupTreePath.append(markup.indexInParent)
            currentMarkup = parent
        }

        self.markupTreePath = markupTreePath.reversed()
        self.role = role
    }
}
