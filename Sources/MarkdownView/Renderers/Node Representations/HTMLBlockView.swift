//
//  HTMLBlockView.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/20.
//

import SwiftUI

struct HTMLBlockView: View {
    var html: String
    @State private var contentSize = CGSize.zero
    
    var body: some View {
        HTMLView(
            html,
            onContentHeightChange: { height in
                contentSize.height = height
            }
        )
        .frame(maxWidth: .infinity)
        .frame(height: max(contentSize.height, 1))
    }
}
