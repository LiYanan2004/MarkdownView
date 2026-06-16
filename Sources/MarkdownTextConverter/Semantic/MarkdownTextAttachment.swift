//
//  MarkdownTextAttachment.swift
//  MarkdownView
//
//  Created by Codex on 2026/6/15.
//

import Markdown

public struct MarkdownTextAttachment {
    public var markup: any Markup

    public var sourceRange: SourceRange? {
        markup.range
    }

    var markupTypeIdentifier: ObjectIdentifier {
        ObjectIdentifier(type(of: markup))
    }

    public init(_ markup: some Markup) {
        self.markup = markup
    }
}
