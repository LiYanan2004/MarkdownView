//
//  MarkdownEditor.swift
//  Examples
//

import SwiftUI

struct MarkdownEditor: View {
    @Binding var markdownText: String

    var body: some View {
        TextEditor(text: $markdownText)
            .font(.body.monospaced())
            .autocorrectionDisabled()
            #if os(iOS) || os(visionOS)
            .textInputAutocapitalization(.never)
            #endif
            .padding()
    }
}

#Preview {
    @Previewable @State var markdownText = ExampleMarkdown.showcase

    MarkdownEditor(markdownText: $markdownText)
}
