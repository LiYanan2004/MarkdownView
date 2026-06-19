//
//  MarkdownTableCellBackgroundStyle.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/18.
//

import SwiftUI

struct MarkdownTableCellBackgroundStyleEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnyShapeStyle? = nil
}

struct MarkdownTableCellBackgroundShapeEnvironmentKey: EnvironmentKey {
    static let defaultValue: _AnyShape = .init(.rect)
}

extension EnvironmentValues {
    var markdownTableCellBackgroundStyle: AnyShapeStyle? {
        get { self[MarkdownTableCellBackgroundStyleEnvironmentKey.self] }
        set { self[MarkdownTableCellBackgroundStyleEnvironmentKey.self] = newValue }
    }
    
    var markdownTableCellBackgroundShape: _AnyShape {
        get { self[MarkdownTableCellBackgroundShapeEnvironmentKey.self] }
        set { self[MarkdownTableCellBackgroundShapeEnvironmentKey.self] = newValue }
    }
}
