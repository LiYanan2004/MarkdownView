//
//  Sequence++.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/1/19.
//

import Foundation

extension Sequence {
    @_spi(Internal)
    public func first<T>(
        byUnwrapping transform: @escaping (Element) throws -> T?
    ) rethrows -> T? {
        try self.lazy.compactMap(transform).first
    }
}
