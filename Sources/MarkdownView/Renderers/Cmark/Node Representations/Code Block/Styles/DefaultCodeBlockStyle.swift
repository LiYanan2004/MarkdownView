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
    
    @State private var attributedCode: AttributedString?
    @State private var codeHighlightTask: Task<Void, Error>?
    
    @State private var showCopyButton = false
    @State private var codeCopied = false
    
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
        .lineSpacing(4)
        .font(fontGroup.codeBlock)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        #if os(macOS) || os(iOS)
        .safeAreaInset(edge: .top, spacing: 0) {
            copyButton
                .frame(maxWidth: .infinity, alignment: .trailing)
                .background(.quaternary.opacity(0.3))
                .overlay {
                    Rectangle()
                        .stroke(.quaternary, lineWidth: 0.5)
                        .scaleEffect(x: 1.5, y: 1.5, anchor: .bottom)
                }
        }
        #endif
        .background(.background)
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary)
        }
    }
    
    @ViewBuilder
    private var codeLanguage: some View {
        if let language = codeBlockConfiguration.language {
            Text(language.uppercased())
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
    
    private func debouncedHighlight() {
        codeHighlightTask?.cancel()
        codeHighlightTask = Task.detached(priority: .background) {
            try await updateAttributeCode()
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
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
        } catch is CancellationError {
            // The task has been cancelled
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
    
    private var copyButton: some View {
        Button {
            #if os(macOS)
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(codeBlockConfiguration.code, forType: .string)
            #elseif os(iOS) || os(visionOS)
            UIPasteboard.general.string = codeBlockConfiguration.code
            #endif
            Task {
                withAnimation(.spring()) {
                    codeCopied = true
                }
                try await Task.sleep(nanoseconds: 2_000_000_000)
                withAnimation(.spring()) {
                    codeCopied = false
                }
            }
        } label: {
            Group {
                if codeCopied {
                    Label("Copied", systemImage: "checkmark")
                        .transition(.opacity.combined(with: .scale))
                } else {
                    Label("Copy", systemImage: "square.on.square")
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(.accessory)
        .font(.callout.weight(.medium))
        #if os(macOS)
        .padding(8)
        #else
        .padding(16)
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

// MARK: - Supplementary

fileprivate struct AccessoryButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        #if os(macOS)
        if #available(macOS 14.0, *) {
            Button(role: configuration.role) {
                configuration.trigger()
            } label: {
                configuration.label
            }
            .buttonStyle(.accessoryBar)
        } else {
            Button(role: configuration.role) {
                configuration.trigger()
            } label: {
                configuration.label
            }
            .buttonStyle(.plain)
        }
        #else
        Button(role: configuration.role) {
            configuration.trigger()
        } label: {
            configuration.label
        }
        .buttonStyle(.plain)
        #endif
    }
}

extension PrimitiveButtonStyle where Self == AccessoryButtonStyle {
    static fileprivate var accessory: AccessoryButtonStyle {
        .init()
    }
}
