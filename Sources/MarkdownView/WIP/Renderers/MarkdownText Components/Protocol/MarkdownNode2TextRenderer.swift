//
//  MarkdownNode2TextRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/12.
//

import Foundation
import SwiftUI

protocol MarkdownNode2TextRenderer {
    typealias Context = MarkdownNode2TextRendererContext
    
    @TextBuilder func body(context: Context) -> Text
}

struct MarkdownNode2TextRendererContext: Sendable {
    var node: MarkdownTextNode
    var renderConfiguration: MarkdownRenderConfiguration
}
