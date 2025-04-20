//
//  MarkdownTableCellBackgroundStyle.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/18.
//

import SwiftUI

struct MarkdownTableRowBackgroundStyleEnvironmentKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: AnyShapeStyle? = nil
}

struct MarkdownTableRowBackgroundShapeEnvironmentKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: any Shape = .rect
}

extension EnvironmentValues {
    var markdownTableRowBackgroundStyle: AnyShapeStyle? {
        get { self[MarkdownTableRowBackgroundStyleEnvironmentKey.self] }
        set { self[MarkdownTableRowBackgroundStyleEnvironmentKey.self] = newValue }
    }
    
    var markdownTableRowBackgroundShape: any Shape {
        get { self[MarkdownTableRowBackgroundShapeEnvironmentKey.self] }
        set { self[MarkdownTableRowBackgroundShapeEnvironmentKey.self] = newValue }
    }
}
