//
//  ContentView.swift
//  Examples
//
//  Created by Yanan Li on 2026/6/19.
//

import SwiftUI
import MarkdownView

struct ContentView: View {
    @State private var source = StreamingMarkdownSource(ExampleMarkdown.showcase)
    @State private var rendererKind = MarkdownRendererKind.markdownView

    @State private var isMarkdownEditorPresented = false
    @State private var streamingTask: Task<Void, Error>?

    var body: some View {
        NavigationStack {
            MarkdownPreview(
                source: source,
                rendererKind: rendererKind
            )
            .toolbar(content: toolbarContent)
        }
    }
    
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem {
            Button(
                "Stream",
                systemImage: streamingTask == nil ? "dot.radiowaves.left.and.right" : "stop.fill"
            ) {
                if streamingTask == nil {
                    streamingTask = Task {
                        source.text = ""
                        
                        for character in ExampleMarkdown.showcase {
                            if Task.isCancelled {
                                break
                            }
                            
                            source.text += String(character)
                            
                            try await Task.sleep(for: .milliseconds(1))
                        }
                        
                        streamingTask = nil
                    }
                } else {
                    streamingTask?.cancel()
                }
            }
        }

        ToolbarItem {
            Button("Edit") {
                isMarkdownEditorPresented = true
            }
            .popover(isPresented: $isMarkdownEditorPresented) {
                MarkdownEditor(markdownText: $source.text)
                    .scrollContentBackground(.hidden)
                    .frame(idealWidth: 400)
            }
        }
        
        ToolbarItem(placement: .navigation) {
            Picker("Renderer", selection: $rendererKind) {
                ForEach(MarkdownRendererKind.allCases) { rendererKind in
                    Text(rendererKind.title)
                        .tag(rendererKind)
                }
            }
            .fixedSize()
        }
    }
}

#Preview {
    ContentView()
}
