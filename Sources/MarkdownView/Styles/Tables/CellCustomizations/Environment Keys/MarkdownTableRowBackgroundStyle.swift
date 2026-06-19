//
//  MarkdownTableCellBackgroundStyle.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/18.
//

import SwiftUI

struct MarkdownTableRowBackgroundStyleEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnyShapeStyle? = nil
}

struct MarkdownTableRowBackgroundShapeEnvironmentKey: EnvironmentKey {
    static let defaultValue: _AnyShape = .init(.rect)
}

extension EnvironmentValues {
    var markdownTableRowBackgroundStyle: AnyShapeStyle? {
        get { self[MarkdownTableRowBackgroundStyleEnvironmentKey.self] }
        set { self[MarkdownTableRowBackgroundStyleEnvironmentKey.self] = newValue }
    }
    
    var markdownTableRowBackgroundShape: _AnyShape {
        get { self[MarkdownTableRowBackgroundShapeEnvironmentKey.self] }
        set { self[MarkdownTableRowBackgroundShapeEnvironmentKey.self] = newValue }
    }
}
