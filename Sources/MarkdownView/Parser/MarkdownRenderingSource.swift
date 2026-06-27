//
//  MarkdownRenderingSource.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/27.
//

import Markdown

enum MarkdownRenderingSource: Sendable {
    case rawText(String)
    case document(Markdown.Document)
}
