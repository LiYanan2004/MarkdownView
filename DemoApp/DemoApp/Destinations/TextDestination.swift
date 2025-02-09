//
//  TextDestination.swift
//  DemoApp
//
//  Created by LiYanan2004 on 2024/10/23.
//

import SwiftUI
import MarkdownView

struct TextDestination: View {
    var body: some View {
        MarkdownView("""
        # MarkdownView
        ## Heading 2
        ### Heading 3
        #### Heading 4
        
        __MarkdownView__ is built with `swift-markdown`.
        
        It supports _SVG Rendering_, which is pretty great.
        """)
    }
}

#Preview {
    ScrollView {
        TextDestination()
    }
    .frame(width: 500)
}
