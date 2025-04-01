//
//  MarkdownTextRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/11.
//

import SwiftUI

@MainActor
@preconcurrency
struct MarkdownTextRenderer {
    var environment: EnvironmentValues
    
    func renderMarkdownContent(_ markdownContent: MarkdownContent) -> MarkdownTextNode {
        var renderer = self
        return renderer.visit(markdownContent.document)
    }
}
