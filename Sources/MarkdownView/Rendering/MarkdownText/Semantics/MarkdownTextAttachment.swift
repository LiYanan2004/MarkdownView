//
//  MarkdownTextAttachment.swift
//  MarkdownView
//
//  Created by Codex on 2026/6/15.
//

import Markdown

struct MarkdownTextAttachment {
    var markup: any Markup

    var sourceRange: SourceRange? {
        markup.range
    }

    var markupTypeIdentifier: ObjectIdentifier {
        ObjectIdentifier(type(of: markup))
    }

    init(_ markup: some Markup) {
        self.markup = markup
    }
}
