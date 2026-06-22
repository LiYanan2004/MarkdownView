//
//  ContentView.swift
//  Examples
//
//  Created by Yanan Li on 2026/6/19.
//

import SwiftUI

struct ContentView: View {
    @State private var markdownText = ExampleMarkdown.showcase

    #if os(iOS) || os(macOS)
    @State private var rendererKind = MarkdownRendererKind.markdownText
    #else
    @State private var rendererKind = MarkdownRendererKind.markdownView
    #endif

    @State private var isMarkdownEditorPresented = false
    @State private var streamingTask: Task<Void, Error>?

    var body: some View {
        NavigationStack {
            MarkdownPreview(
                markdownText: markdownText,
                rendererKind: rendererKind
            )
            .toolbar {
                ToolbarItem {
                    Button(
                        "Stream",
                        systemImage: streamingTask == nil ? "dot.radiowaves.left.and.right" : "stop.fill"
                    ) {
                        if streamingTask == nil {
                            streamingTask = Task {
                                markdownText = ""
                                
                                var copy = ExampleMarkdown.showcase
                                while !copy.isEmpty {
                                    if Task.isCancelled {
                                        break
                                    }
                                    
                                    let char = String(copy.removeFirst())
                                    markdownText += String(char)
                                    
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
                        MarkdownEditor(markdownText: $markdownText)
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
    }
}

#Preview {
    ContentView()
}
