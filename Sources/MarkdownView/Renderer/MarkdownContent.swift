//
//  MarkdownContent.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import Foundation
import Markdown

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

// MARK: - Parsed

public struct ParsedMarkdownContent: Sendable {
    var raw: RawMarkdownContent
    
    internal init(raw: RawMarkdownContent) {
        self.raw = raw
    }
    
    private var cache = Cache()
    private class Cache: @unchecked Sendable {
        var document: Document?
    }
    
    public var document: Document {
        if let cachedDocument = cache.document {
            return cachedDocument
        }
        
        var options = ParseOptions()
        options.insert(.parseBlockDirectives)
        
        let document = Document(
            parsing: raw.text,
            source: raw.source,
            options: options
        )
        cache.document = document
        
        return document
    }
}

extension ParsedMarkdownContent: Hashable {
    public static func == (lhs: ParsedMarkdownContent, rhs: ParsedMarkdownContent) -> Bool {
        lhs.raw == rhs.raw
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(raw)
    }
}
