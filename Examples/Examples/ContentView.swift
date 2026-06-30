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
    @State private var isStreamingConfigurationPresented = false
    @State private var streamingTask: Task<Void, Error>?
    @State private var streamingIntervalMilliseconds = 1.0
    @State private var charactersPerChunk = 1.0

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
                    startStreaming()
                } else {
                    streamingTask?.cancel()
                }
            }
        }

        ToolbarItem {
            Button(
                "Streaming Options",
                systemImage: "slider.horizontal.3"
            ) {
                isStreamingConfigurationPresented = true
            }
            .popover(isPresented: $isStreamingConfigurationPresented) {
                streamConfigurationPopup
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
    
    private var streamConfigurationPopup: some View {
        Form {
            VStack(alignment: .leading, spacing: 8) {
                LabeledContent("Interval") {
                    Text("\(Int(streamingIntervalMilliseconds.rounded())) ms")
                        .monospacedDigit()
                }

                Slider(
                    value: $streamingIntervalMilliseconds,
                    in: 1 ... 1000
                )
            }

            VStack(alignment: .leading, spacing: 8) {
                LabeledContent("Characters") {
                    Text("\(Int(charactersPerChunk.rounded()))")
                        .monospacedDigit()
                }

                Slider(
                    value: $charactersPerChunk,
                    in: 1 ... 32
                )
            }
        }
        .formStyle(.grouped)
        .frame(width: 280)
    }

    private func startStreaming() {
        let intervalMilliseconds = Int(streamingIntervalMilliseconds.rounded())
        let chunkSize = Int(charactersPerChunk.rounded())

        streamingTask = Task {
            defer {
                streamingTask = nil
            }

            source.text = ""

            let characters = Array(ExampleMarkdown.showcase)
            var currentIndex = 0

            while currentIndex < characters.count {
                if Task.isCancelled {
                    break
                }

                let nextIndex = min(currentIndex + chunkSize, characters.count)
                source.text += String(characters[currentIndex..<nextIndex])
                currentIndex = nextIndex

                if currentIndex < characters.count {
                    try await Task.sleep(for: .milliseconds(intervalMilliseconds))
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
