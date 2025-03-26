//
//  DefaultCodeBlockStyle.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/3/25.
//

import SwiftUI

#if canImport(Highlightr)
@preconcurrency import Highlightr
#endif

/// Default code block style that applies to a MarkdownView.
public struct DefaultCodeBlockStyle: CodeBlockStyle {
    /// Theme configuration in the current context.
    public var highlighterTheme: CodeHighlighterTheme
    
    public init(
        highlighterTheme: CodeHighlighterTheme = CodeHighlighterTheme(
            lightModeThemeName: "xcode",
            darkModeThemeName: "dark"
        )
    ) {
        self.highlighterTheme = highlighterTheme
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        DefaultMarkdownCodeBlock(
            codeBlockConfiguration: configuration,
            theme: highlighterTheme
        )
    }
}

extension CodeBlockStyle where Self == DefaultCodeBlockStyle {
    /// Default code block theme with light theme called "xcode" and dark theme called "dark".
    static public var `default`: DefaultCodeBlockStyle { .init() }
    
    /// Default code block theme with customized light & dark themes.
    static public func `default`(
        lightTheme: String = "xcode",
        darkTheme: String = "dark"
    ) -> DefaultCodeBlockStyle {
        .init(
            highlighterTheme: CodeHighlighterTheme(
                lightModeThemeName: lightTheme,
                darkModeThemeName: darkTheme
            )
        )
    }
}

// MARK: - Default View Implementation

struct DefaultMarkdownCodeBlock: View {
    var codeBlockConfiguration: CodeBlockStyleConfiguration
    
    var theme: CodeHighlighterTheme
    @Environment(\.colorScheme) private var colorScheme
    
    @Environment(\.markdownRendererConfiguration.fontGroup) private var fontGroup
    
    @State private var showCopyButton = false
    @State private var attributedCode: AttributedString?
    @State private var codeHighlightTask: Task<Void, Error>?
    
    var body: some View {
        Group {
            if let attributedCode {
                Text(attributedCode)
            } else {
                Text(codeBlockConfiguration.code)
            }
        }
        .task(id: codeHighlightingConfiguration, immediateHighlight)
        .onChange(of: codeBlockConfiguration) {
            debouncedHighlight()
        }
        .lineSpacing(5)
        .font(fontGroup.codeBlock)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
        #if os(macOS) || os(iOS)
        .overlay(alignment: .topTrailing) {
            if showCopyButton {
                CopyButton(content: codeBlockConfiguration.code)
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
        if let language = codeBlockConfiguration.language {
            Text(language.uppercased())
                .font(.callout)
                .padding(8)
                .foregroundStyle(.secondary)
        }
    }
    
    private func debouncedHighlight() {
        codeHighlightTask?.cancel()
        codeHighlightTask = Task.detached(priority: .background) {
            try await updateAttributeCode()
            try await Task.sleep(for: .seconds(0.2))
            try await highlight()
        }
    }
    
    private func updateAttributeCode() async throws {
        guard var attributedCode = attributedCode else { return }
        let characters = attributedCode.characters
        
        for difference in codeBlockConfiguration.code.difference(from: characters) {
            try Task.checkCancellation()
            
            switch difference {
            case .insert(let offset, let insertion, _):
                let insertionPoint = attributedCode.index(
                    attributedCode.startIndex,
                    offsetByCharacters: offset
                )
                attributedCode.insert(
                    AttributedString(String(insertion)),
                    at: insertionPoint
                )
            case .remove(let offset, _, _):
                let removalLowerBound = attributedCode.index(attributedCode.startIndex, offsetByCharacters: offset)
                let removalUpperBound = attributedCode.index(afterCharacter: removalLowerBound)
                attributedCode.removeSubrange(removalLowerBound..<removalUpperBound)
            }
        }
        
        try Task.checkCancellation()
        await MainActor.run {
            self.attributedCode = attributedCode
        }
    }
    
    private func immediateHighlight() async {
        do {
            try await highlight()
        } catch {
            logger.error("\(String(describing: error), privacy: .public)")
        }
    }
    
    @Sendable
    nonisolated private func highlight() async throws {
        #if canImport(Highlightr)
        try Task.checkCancellation()
        let highlightr = Highlightr()!
        await highlightr.setTheme(to: theme.themeName(for: colorScheme))
        
        let specifiedLanguage = codeBlockConfiguration.language?.lowercased() ?? ""
        let language = highlightr.supportedLanguages()
            .first(where: { $0.localizedCaseInsensitiveCompare(specifiedLanguage) == .orderedSame })
        
        try Task.checkCancellation()
        let code = codeBlockConfiguration.code
        guard let highlightedCode = highlightr.highlight(code, as: language) else { return }
        let attributedCode = NSMutableAttributedString(
            attributedString: highlightedCode
        )
        attributedCode.removeAttribute(.font, range: NSMakeRange(0, attributedCode.length))
        
        try await MainActor.run {
            try Task.checkCancellation()
            self.attributedCode = AttributedString(attributedCode)
        }
        #endif
    }
}

extension DefaultMarkdownCodeBlock {
    struct CodeHighlightingConfiguration: Hashable, Sendable {
        var theme: CodeHighlighterTheme
        var colorScheme: ColorScheme
    }
    
    private var codeHighlightingConfiguration: CodeHighlightingConfiguration {
        CodeHighlightingConfiguration(
            theme: theme,
            colorScheme: colorScheme
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
