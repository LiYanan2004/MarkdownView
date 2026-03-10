//
//  MarkdownAttachmentReplacementPolicy.swift
//  MarkdownView
//
//  Created by Codex on 2026/2/6.
//

import Foundation
import Markdown

@MainActor
struct MarkdownAttachmentReplacementPolicy {
    func replacementForBlockDirective(_ blockDirective: BlockDirective) -> AttributedString? {
        let wrappedString = blockDirective
            .children
            .compactMap { $0.format() }
            .joined(separator: "\n")
        guard !wrappedString.isEmpty else {
            return nil
        }
        return AttributedString(wrappedString)
    }
    
    func replacementForBlockQuote(
        childAttributedStrings: [AttributedString]
    ) -> AttributedString? {
        guard !childAttributedStrings.isEmpty else {
            return nil
        }
        
        return childAttributedStrings.reduce(into: AttributedString()) { attributedString, row in
            attributedString += row
            attributedString += "\n"
        }
    }
    
    func replacementForImage(_ image: Markdown.Image) -> AttributedString? {
        let plainText = image.plainText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !plainText.isEmpty else {
            return nil
        }
        return AttributedString(plainText)
    }
    
    func replacementForCodeBlock(_ codeBlock: CodeBlock) -> AttributedString? {
        guard !codeBlock.code.isEmpty else {
            return nil
        }
        return AttributedString(codeBlock.code)
    }
    
    func replacementForHTMLBlock(_ htmlBlock: HTMLBlock) -> AttributedString? {
        guard !htmlBlock.rawHTML.isEmpty else {
            return nil
        }
        return AttributedString(
            htmlBlock.rawHTML,
            attributes: AttributeContainer().isHTML(true)
        )
    }
    
    func replacementForTableRows(_ rows: [AttributedString]) -> AttributedString? {
        guard !rows.isEmpty else {
            return nil
        }
        
        return rows.reduce(into: AttributedString()) { attributedString, row in
            attributedString += row
            attributedString += "\n"
        }
    }
}
