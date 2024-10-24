//
//  BlockDirectiveDestination.swift
//  DemoApp
//
//  Created by LiYanan2004 on 2024/10/24.
//

import SwiftUI
import MarkdownView

struct BlockDirectiveDestination: View {
    @State private var text = #"""
    @note {
    This is a note directive block. You can use it to highlight important information or provide additional context to users.
    }
    """#
    
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
                MarkdownView(text: text)
                    .blockDirectiveProvider(.note, for: "note")
            } header: {
                Text("MarkdownView")
                    .font(.headline)
            }
        }
    }
}

#Preview {
    ScrollView {
        BlockDirectiveDestination()
            .scenePadding()
            .frame(width: 500)
    }
}

// MARK: - Custom Note Block Directive Provider

struct NoteBlockDirective: BlockDirectiveDisplayable {
    func makeView(arguments: [BlockDirectiveArgument], text: String) -> some View {
        Text(text)
            .padding(20)
            .background(
                .yellow.secondary,
                in: .rect(cornerRadius: 12)
            )
    }
}
 
// MARK: - Convenience

extension BlockDirectiveDisplayable where Self == NoteBlockDirective {
    static var note: NoteBlockDirective { .init() }
}
