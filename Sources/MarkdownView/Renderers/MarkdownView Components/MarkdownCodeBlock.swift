//
//  MarkdownCodeBlock.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/22.
//

import SwiftUI

#if canImport(Highlightr)
@preconcurrency import Highlightr
#endif

struct MarkdownCodeBlock: View {
    var language: String?
    var code: String
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    @State private var showCopyButton = false
    @State private var attributedCode: AttributedString?
    
    var body: some View {
        Group {
            if let attributedCode {
                Text(attributedCode)
            } else {
                Text(code)
            }
        }
        .task(id: codeBlockStorage) {
            highlight()
        }
        .lineSpacing(5)
        .font(configuration.fontGroup.codeBlock)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
        #if os(macOS) || os(iOS)
        .overlay(alignment: .topTrailing) {
            if showCopyButton {
                CopyButton(content: code)
                    .padding(8)
                    .transition(.opacity.animation(.easeInOut))
            }
        }
        .onHover { showCopyButton = $0 }
        #endif
        .overlay(alignment: .bottomTrailing) {
            codeLanguage
        }
    }
    
    @ViewBuilder
    private var codeLanguage: some View {
        if let language {
            Text(language.uppercased())
                .font(.callout)
                .padding(8)
                .foregroundStyle(.secondary)
        }
    }

    private func highlight() {
        #if canImport(Highlightr)
        let highlightr = Highlightr()!
        highlightr.setTheme(to: configuration.currentCodeHighlightTheme)
        
        let specifiedLanguage = language?.lowercased() ?? ""
        let language = highlightr.supportedLanguages()
            .first(where: { $0.localizedCaseInsensitiveCompare(specifiedLanguage) == .orderedSame })
        
        guard let highlightedCode = highlightr.highlight(code, as: language) else { return }
        let code = NSMutableAttributedString(
            attributedString: highlightedCode
        )
        code.removeAttribute(.font, range: NSMakeRange(0, code.length))
        
        attributedCode = AttributedString(code)
        #endif
    }
}

extension MarkdownCodeBlock {
    /// A storage that holds the full information about this code block, and refresh the code block if anything has changed.
    struct CodeBlockStorage: Hashable {
        var code: String
        var language: String?
        var theme: String
    }
    
    private var codeBlockStorage: CodeBlockStorage {
        CodeBlockStorage(
            code: code,
            language: language,
            theme: configuration.currentCodeHighlightTheme
        )
    }
}

// MARK: - Copy Button

#if os(macOS) || os(iOS)
struct CopyButton: View {
    var content: String
    @State private var copied = false
    #if os(macOS)
    @ScaledMetric private var size = 12
    #else
    @ScaledMetric private var size = 18
    #endif
    @State private var isHovering = false
    
    var body: some View {
        Button(action: copy) {
            Group {
                if copied {
                    Image(systemName: "checkmark")
                        .transition(.opacity.combined(with: .scale))
                } else {
                    Image(systemName: "doc.on.clipboard")
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .font(.system(size: size))
            .frame(width: size, height: size)
            .padding(8)
            .contentShape(Rectangle())
        }
        .foregroundStyle(.primary)
        .background(
            .quaternary.opacity(0.2),
            in: RoundedRectangle(cornerRadius: 5, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
        }
        .brightness(isHovering ? 0.3 : 0)
        .buttonStyle(.borderless) // Only use `.borderless` can behave correctly when text selection is enabled.
        .onHover { isHovering = $0 }
    }
    
    private func copy() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(content, forType: .string)
        #else
        UIPasteboard.general.string = content
        #endif
        Task {
            withAnimation(.spring()) {
                copied = true
            }
            try await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation(.spring()) {
                copied = false
            }
        }
    }
}
#endif
