//
//  MarkdownContent.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/27.
//

import Foundation
import Markdown

enum MarkdownContent: Sendable, Equatable {
    case rawText(String)
    case parsedDocument(MarkdownParseResult)
    
    func parse(with options: MarkdownDocumentParsingOptions = []) -> MarkdownParseResult {
        switch self {
            case .rawText(let sourceText):
                let request = MarkdownParseRequest(
                    sourceText: sourceText,
                    parsingOptions: options
                )
                return MarkdownDocumentParser.parse(request)
                
            case .parsedDocument(let parsedDocument):
                return parsedDocument
        }
    }
}
