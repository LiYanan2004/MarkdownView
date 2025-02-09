//
//  MarkdownResource.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import Foundation
import Markdown

enum MarkdownContent: Sendable, Hashable {
    case plainText(String)
    case url(URL)
    
    var text: String {
        switch self {
        case .plainText(let text):
            return text
        case .url(let url):
            return (try? String(contentsOf: url)) ?? ""
        }
    }
    
    var source: URL? {
        if case .url(let url) = self {
            return url
        }
        return nil
    }
}
