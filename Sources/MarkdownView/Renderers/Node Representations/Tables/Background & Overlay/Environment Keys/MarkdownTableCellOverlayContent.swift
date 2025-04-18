//
//  MarkdownTableCellOverlayContent.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/18.
//

import SwiftUI

struct MarkdownTableCellOverlayContentEnvironmentKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: AnyView? = nil
}

extension EnvironmentValues {
    var markdownTableCellOverlayContent: AnyView? {
        get { self[MarkdownTableCellOverlayContentEnvironmentKey.self] }
        set { self[MarkdownTableCellOverlayContentEnvironmentKey.self] = newValue }
    }
}
