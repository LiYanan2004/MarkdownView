//
//  AllowingModifyThroughKeyPath.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import Foundation

protocol AllowingModifyThroughKeyPath { }

extension AllowingModifyThroughKeyPath {
    public func with<T>(_ keyPath: WritableKeyPath<Self, T>, _ newValue: T) -> Self {
        var copy = self
        copy[keyPath: keyPath] = newValue
        return copy
    }
}
