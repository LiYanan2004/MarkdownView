//
//  MarkdownContent.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/27.
//

import Foundation
import Combine
@preconcurrency import Markdown

/// An observable object that manages the content of the markdown and provides the parsed document.
public final class MarkdownContent: ObservableObject {
    var store: ParsedDocumentStore!
    
    @Published private var raw: Raw {
        willSet {
            if raw != newValue {
                store.resetStorage()
            }
        }
    }
    
    /// The markdown text.
    public var markdown: String {
        get throws {
            try raw.markdownText
        }
    }
    
    internal init(_ source: Raw) {
        self.raw = source
        self.store = ParsedDocumentStore(self)
    }
    
    /// Parsed document.
    ///
    /// - parameter parseOptions: The parse options to use for markdown parsing or `nil` if you want to either use any cached version or parse the markdown with default options.
    ///
    /// This API try to find parsed document with given `parseOptions` in the cache.
    /// If there is no matches, then it tries to parse the content and cache it for future query.
    ///
    /// If the `parseOptions` is set to `nil` and there is any cached document available, the first cached result will be returned.
    internal func document(options: ParseOptions = ParseOptions()) -> Document {
        store.parse(raw, options: options)
    }
}

extension MarkdownContent {
    /// Creates an instance from a plain string.
    public convenience init(_ text: String) {
        self.init(.plainText(text))
    }
    
    /// Creates an instance whose contents are loaded from a URL.
    public convenience init(_ url: URL) {
        self.init(.url(url))
    }

    /// Updates the source of the markdown content.
    /// - parameter content: The markdown text.
    public func updateContent(_ content: String) {
        self.raw = .plainText(content)
    }
    
    /// Updates the source of the markdown content.
    /// - parameter content: The URL of the markdown file.
    public func updateContent(_ content: URL) {
        self.raw = .url(content)
    }
}

extension MarkdownContent {
    class ParsedDocumentStore: /* NSLock */ @unchecked Sendable {
        private var lock = NSLock()
        private var caches: [ParseOptions.RawValue : Document] = [:]
        unowned var content: MarkdownContent
        
        init(_ content: MarkdownContent) {
            self.content = content
        }
        
        fileprivate func parse(
            _ source: MarkdownContent.Raw,
            options: ParseOptions = ParseOptions()
        ) -> Document {
            lock.lock()
            defer { lock.unlock() }
            
            if let cached = caches[options.rawValue] {
                return cached
            }
            
            let text: String
            do {
                text = try source.markdownText
            } catch {
                text = ""
                logger.error("Unable to retrieve markdown content in string format: \(error). (fallback to empty string).")
            }
            
            let document = Document(
                parsing: text,
                source: nil,
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
        
        func resetStorage() {
            lock.lock()
            defer { lock.unlock() }
            
            caches = [:]
        }
    }
}

extension MarkdownContent: ExpressibleByStringLiteral {
    public convenience init(stringLiteral value: String) {
        self.init(value)
    }
}

extension MarkdownContent {
    /// A representation of where the Markdown originates.
    public enum Raw: Hashable {
        case plainText(String)
        case url(URL)
        
        public var markdownText: String {
            get throws {
                switch self {
                    case .plainText(let string):
                        string
                    case .url(let url):
                        try String(contentsOf: url, encoding: .utf8)
                }
            }
        }
    }
}
