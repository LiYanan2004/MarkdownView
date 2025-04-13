//
//  MarkdownContent.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import Foundation
@preconcurrency import Markdown

// MARK: - Raw

enum RawMarkdownContent: Sendable, Hashable {
    case plainText(String)
    case url(URL)
    
    public var text: String {
        switch self {
        case .plainText(let text):
            return text
        case .url(let url):
            return (try? String(contentsOf: url)) ?? ""
        }
    }
    
    public var source: URL? {
        if case .url(let url) = self {
            return url
        }
        return nil
    }
}

// MARK: - Parsed Content

/// A Sendable markdown content that can be used to render content and supports on-demand parsing.
public struct MarkdownContent: Sendable {
    var raw: RawMarkdownContent
    
    /// Parsed markdown document.
    public var document: Document
    
    internal init(raw: RawMarkdownContent) {
        self.raw = raw
        
        func parseRawContent() -> Document {
            let expcapedRawMarkdown = raw.text
                .replacingOccurrences(of: "\\", with: "\\\\")
            var options = ParseOptions()
            options.insert(.parseBlockDirectives)
            
            return Document(
                parsing: expcapedRawMarkdown,
                source: raw.source,
                options: options
            )
        }
        
        self.document = parseRawContent()
    }
}

extension MarkdownContent: Hashable {
    public static func == (lhs: MarkdownContent, rhs: MarkdownContent) -> Bool {
        lhs.raw == rhs.raw
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(raw)
    }
}
