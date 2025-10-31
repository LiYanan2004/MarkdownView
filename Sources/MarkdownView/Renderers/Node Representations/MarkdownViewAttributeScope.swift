//
//  MarkdownViewAttributeScope.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/20.
//

import Foundation

extension AttributeScopes {
    struct MarkdownViewAttributeScope: AttributeScope {
        let isHTML: IsHTMLAttribute
    }
}

extension AttributeDynamicLookup {
    subscript<T: AttributedStringKey>(dynamicMember keyPath: KeyPath<AttributeScopes.MarkdownViewAttributeScope, T>) -> T {
        return self[T.self]
    }
}

extension AttributeScopes.MarkdownViewAttributeScope {
    enum IsHTMLAttribute: AttributedStringKey {
        static let name: String = "isHTML"
        
        typealias Value = Bool
    }
}
