//
//  MarkdownStyledCodeBlock.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/3/25.
//

import SwiftUI

struct MarkdownStyledCodeBlock: View {
    var configuration: MarkdownCodeBlockStyleConfiguration

    init(configuration: MarkdownCodeBlockStyleConfiguration) {
        self.configuration = configuration
    }
    @Environment(\.codeBlockStyle) private var codeBlockStyle
    
    var body: some View {
        codeBlockStyle
            .makeBody(configuration: configuration)
            .erasedToAnyView()
    }
}
