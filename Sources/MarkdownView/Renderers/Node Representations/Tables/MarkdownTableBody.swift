//
//  MarkdownTableBody.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/18.
//

import SwiftUI
import Markdown

struct MarkdownTableBody: View {
    var tableBody: Markdown.Table.Body
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    
    var body: some View {
        ForEach(Array(tableBody.children.enumerated()), id: \.offset) { (_, row) in
            CmarkNodeVisitor(configuration: configuration)
                .makeBody(for: row)
                .font(configuration.fontGroup.tableBody)
                .foregroundStyle(configuration.foregroundStyleGroup.tableBody)
        }
    }
}
