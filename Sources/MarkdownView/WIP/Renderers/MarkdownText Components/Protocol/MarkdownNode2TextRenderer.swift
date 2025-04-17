//
//  MarkdownNode2TextRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/12.
//

import Foundation
import SwiftUI

@MainActor
@preconcurrency
protocol MarkdownNode2TextRenderer {
    typealias Context = MarkdownNode2TextRendererContext
    
    @MainActor
    @TextBuilder
    func body(context: Context) -> Text
}

@MainActor
@preconcurrency
struct MarkdownNode2TextRendererContext: Sendable {
    var node: MarkdownTextNode
    var environment: EnvironmentValues
    var rendererConfiguration: MarkdownRendererConfiguration {
        environment.markdownRendererConfiguration
    }
}
