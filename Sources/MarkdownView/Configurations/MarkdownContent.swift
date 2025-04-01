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

// MARK: - Parsed Content

/// A Sendable markdown content that can be used to render content and supports on-demand parsing.
public struct MarkdownContent: Sendable {
    var raw: RawMarkdownContent
    private var escapedText: String {
        raw.text
            .replacingOccurrences(of: "\\", with: "\\\\")
    }
    
    internal init(raw: RawMarkdownContent) {
        self.raw = raw
    }
    
    private var cache = Cache()
    private class Cache: @unchecked Sendable {
        var document: Document?
    }
    
    /// Parsed markdown document.
    public var document: Document {
        if let cachedDocument = cache.document {
            return cachedDocument
        }
        
        var options = ParseOptions()
        options.insert(.parseBlockDirectives)
        
        // Use the preprocessed text instead of raw text
        let document = Document(
            parsing: preprocessedText,
            source: raw.source,
            options: options
        )
        cache.document = document
        
        return document
    }
    // ORIGINAL
//    public var document: Document {
//        if let cachedDocument = cache.document {
//            return cachedDocument
//        }
//        
//        var options = ParseOptions()
//        options.insert(.parseBlockDirectives)
//        
//        let document = Document(
//            parsing: escapedText,
//            source: raw.source,
//            options: options
//        )
//        cache.document = document
//        
//        return document
//    }
}

extension MarkdownContent: Hashable {
    public static func == (lhs: MarkdownContent, rhs: MarkdownContent) -> Bool {
        lhs.raw == rhs.raw
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(raw)
    }
}
