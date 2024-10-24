//
//  OverviewDestination.swift
//  DemoApp
//
//  Created by LiYanan2004 on 2024/10/23.
//

import SwiftUI
import MarkdownView

struct OverviewDestination: View {
    var body: some View {
        MarkdownView(text: """
        # MarkdownView
        
        Welcome to MarkdownView Demo App.
        
        MarkdownView is a dedicated package that provides a solution for Markdown text rendering. 
        
        It renders content as native SwiftUI View and supports built-in accessibility features.
        
        ### MarkdownView supports
        - Formatted Text, including: **bold**, _italic_, ~strike through~, [Link](https://apple.com), `inline code`
        - Lists
            - Unordered List
            1. Ordered List
        - Quote
        - Code Block
        - Image, including SVG-based content
        - Table
        """)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            OverviewDestination()
        }
    }
}
