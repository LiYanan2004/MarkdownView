//
//  InteractDestination.swift
//  DemoApp
//
//  Created by LiYanan2004 on 2024/10/24.
//

import SwiftUI
import MarkdownView

struct InteractDestination: View {
    @State private var text = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Section {
                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
                    .font(.body)
                    .lineSpacing(6)
                    .containerRelativeFrame(.vertical, count: 3, span: 1, spacing: 20)
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
                MarkdownView($text)
            } header: {
                Text("MarkdownView")
                    .font(.headline)
            }
        }
    }
}

#Preview {
    ScrollView {
        InteractDestination()
            .scenePadding()
    }
}
