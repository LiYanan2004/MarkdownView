//
//  KeyPathModifiable.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import Foundation

protocol KeyPathModifiable { }

extension KeyPathModifiable {
    public func with<T>(_ keyPath: WritableKeyPath<Self, T>, _ newValue: T) -> Self {
        var copy = self
        copy[keyPath: keyPath] = newValue
        return copy
    }
    
    public mutating func modify<T>(
        _ keyPath: WritableKeyPath<Self, T>,
        _ modify: @escaping (inout T) -> Void
    ) {
        var value = self[keyPath: keyPath]
        defer { self[keyPath: keyPath] = value }
        modify(&value)
    }
}
