//
//  ImageDestination.swift
//  DemoApp
//
//  Created by LiYanan2004 on 2024/10/23.
//

import SwiftUI
import MarkdownView

struct ImageDestination: View {
    var body: some View {
        VStack(alignment: .leading) {
            MarkdownView(text: """
            ### SVG Content
            ![Swift Badge](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FLiYanan2004%2FMarkdownView%2Fbadge%3Ftype%3Dswift-versions)
            ![Platform Badge](https://camo.githubusercontent.com/bf56cba1dd003eb35f7a5bbe930df25b30cec92d78f06d5c0e4cae285865ccb6/68747470733a2f2f696d672e736869656c64732e696f2f656e64706f696e743f75726c3d687474707325334125324625324673776966747061636b616765696e6465782e636f6d2532466170692532467061636b616765732532464c6959616e616e323030342532464d61726b646f776e56696577253246626164676525334674797065253344706c6174666f726d73)
            """)
            
            MarkdownView(text: """
            ### Web Images
            ![](https://avatars.githubusercontent.com/u/37542129?s=400&u=ad6b55151a424db26e94b3b9ba3c57e69f62b56b&v=4)
            """)
        }
        .scenePadding()
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            ImageDestination()
                .frame(width: 300)
        }
    }
}
