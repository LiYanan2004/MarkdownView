//
//  HTMLBlockView.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/20.
//

import SwiftUI

package struct HTMLBlockView: View {
    package var html: String

    package init(html: String) {
        self.html = html
    }
    @State private var contentSize = CGSize.zero
    
    package var body: some View {
        #if canImport(WebKit)
        HTMLView(
            html,
            onContentHeightChange: { height in
                contentSize.height = height
            }
        )
        .frame(maxWidth: .infinity)
        .frame(height: max(contentSize.height, 1))
        #else
        Text(html)
        #endif
    }
}
