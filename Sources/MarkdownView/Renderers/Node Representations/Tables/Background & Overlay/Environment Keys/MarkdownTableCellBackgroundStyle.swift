//
//  MarkdownTableCellBackgroundStyle.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/18.
//

import SwiftUI

struct MarkdownTableCellBackgroundStyleEnvironmentKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: AnyShapeStyle? = nil
}

struct MarkdownTableCellBackgroundShapeEnvironmentKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: any Shape = .rect
}

extension EnvironmentValues {
    var markdownTableCellBackgroundStyle: AnyShapeStyle? {
        get { self[MarkdownTableCellBackgroundStyleEnvironmentKey.self] }
        set { self[MarkdownTableCellBackgroundStyleEnvironmentKey.self] = newValue }
    }
    
    var markdownTableCellBackgroundShape: any Shape {
        get { self[MarkdownTableCellBackgroundShapeEnvironmentKey.self] }
        set { self[MarkdownTableCellBackgroundShapeEnvironmentKey.self] = newValue }
    }
}
