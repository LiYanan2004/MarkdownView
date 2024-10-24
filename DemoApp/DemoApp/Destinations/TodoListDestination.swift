//
//  TodoListDestination.swift
//  DemoApp
//
//  Created by LiYanan2004 on 2024/10/24.
//

import SwiftUI
import MarkdownView

struct TodoListDestination: View {
    @State private var text = """
    - [x] Write the press release
    - [ ] Update the website
    - [ ] Contact the media
    """
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Section {
                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
                    .font(.body)
                    .lineSpacing(6)
                    .padding(8)
                    .background(
                        .background.secondary,
                        in: .rect(cornerRadius: 12)
                    )
            } header: {
                Text("Markdown Text")
                    .font(.headline)
            }
            
            Divider()
            
            Section {
                MarkdownView(text: $text)
            } header: {
                Text("MarkdownView")
                    .font(.headline)
            } footer: {
                Text("You can click the todo items to toggle their status.")
                    .foregroundStyle(.secondary)
            }
        }
        .scenePadding()
    }
}

#Preview {
    ScrollView {
        TodoListDestination()
    }
}
