//
//  RawMarkdownContent.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/27.
//

import Foundation
@preconcurrency import Markdown

/// The raw input of a markdown content.
@_spi(RawMarkdown)
public enum RawMarkdownContent: Sendable, Hashable {
    case plainText(String)
    case url(URL)
    
    @_spi(RawMarkdown)
    public var text: String {
        switch self {
        case .plainText(let text):
            return text
        case .url(let url):
            return (try? String(contentsOf: url)) ?? ""
        }
    }
    
    @_spi(RawMarkdown)
    public var source: URL? {
        if case .url(let url) = self {
            return url
        }
        return nil
    }
}
