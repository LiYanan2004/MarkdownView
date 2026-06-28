//
//  Markdown+Sendable.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/28.
//

import Markdown

// TODO: Remove these when swift-markdown adapts all relevant types for Swift 6.
extension Markdown.Document: @retroactive @unchecked Sendable { }
extension Markdown.Table: @retroactive @unchecked Sendable { }
extension Markdown.Table.Row: @retroactive @unchecked Sendable { }
extension Markdown.OrderedList: @retroactive @unchecked Sendable { }
extension Markdown.UnorderedList: @retroactive @unchecked Sendable { }
extension Markdown.Heading: @retroactive @unchecked Sendable { }
