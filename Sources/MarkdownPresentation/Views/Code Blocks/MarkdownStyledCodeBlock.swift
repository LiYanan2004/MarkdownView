//
//  MarkdownStyledCodeBlock.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/3/25.
//

import SwiftUI

package struct MarkdownStyledCodeBlock: View {
    package var configuration: MarkdownCodeBlockStyleConfiguration

    package init(configuration: MarkdownCodeBlockStyleConfiguration) {
        self.configuration = configuration
    }
    @Environment(\.codeBlockStyle) private var codeBlockStyle
    
    package var body: some View {
        codeBlockStyle
            .makeBody(configuration: configuration)
            .erasedToAnyView()
    }
}
