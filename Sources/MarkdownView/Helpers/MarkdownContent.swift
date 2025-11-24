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
    
    class ParsedDocumentStore: /* NSLock */ @unchecked Sendable {
        private var lock = NSLock()
        private var caches: [ParseOptions.RawValue : Document] = [:]
        
        fileprivate func parse(_ rawContent: RawMarkdownContent, options: ParseOptions = ParseOptions()) -> Document {
            lock.lock()
            defer { lock.unlock() }
            
            if let cached = caches[options.rawValue] {
                return cached
            }
            
            let document = Document(
                parsing: rawContent.text,
                source: rawContent.source,
                options: options
            )
            caches[options.rawValue] = document
            return document
        }
        
        var documents: LazySequence<Dictionary<ParseOptions.RawValue, Document>.Values> {
            lock.withLock {
                caches.values.lazy
            }
        }
        
        var hasParsedDocument: Bool {
            !documents.isEmpty
        }
    }
    var store: ParsedDocumentStore
    
    internal init(raw: RawMarkdownContent) {
        self.raw = raw
        self.store = ParsedDocumentStore()
    }
    
    func parse(options: ParseOptions = ParseOptions()) -> Document {
        store.parse(raw, options: options)
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
