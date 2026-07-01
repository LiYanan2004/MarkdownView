//
//  MarkdownTextInlineViewIdentifier.swift
//  MarkdownView
//
//  Created by Codex on 2026/6/21.
//

import Markdown

struct MarkdownTextInlineViewIdentifier: Hashable {
    enum MathKind: Hashable {
        case inline
        case display
    }

    enum Role: Hashable {
        case blockAttachment
        case customLink
        case listCheckbox
        case math(kind: MathKind, occurrence: Int)
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
