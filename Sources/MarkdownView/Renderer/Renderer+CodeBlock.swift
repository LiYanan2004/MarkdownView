import Markdown
import SwiftUI
#if os(iOS) || os(macOS)
import Highlightr
#endif

// MARK: - Inline Code Block
extension Renderer {
    mutating func visitInlineCode(_ inlineCode: InlineCode) -> Result {
        var attributedString = AttributedString(stringLiteral: inlineCode.code)
        attributedString.foregroundColor = configuration.inlineCodeTintColor
        attributedString.backgroundColor = configuration.inlineCodeTintColor.opacity(0.1)
        return Result(SwiftUI.Text(attributedString))
    }
    
    func visitInlineHTML(_ inlineHTML: InlineHTML) -> Result {
        Result(SwiftUI.Text(inlineHTML.rawHTML))
    }
}

// MARK: - Code Block

extension Renderer {
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> Result {
        Result {
            #if os(watchOS) || os(tvOS)
            SwiftUI.Text(codeBlock.code)
            #else
            HighlightedCodeBlock(
                language: codeBlock.language,
                code: codeBlock.code,
                theme: configuration.codeBlockTheme
            )
            #endif
        }
    }
    
    func visitHTMLBlock(_ html: HTMLBlock) -> Result {
        // Forced conversion of text to view
        Result {
            SwiftUI.Text(html.rawHTML)
        }
    }
}

#if os(iOS) || os(macOS)
struct HighlightedCodeBlock: View {
    var language: String?
    var code: String
    var theme: CodeHighlighterTheme
    
    @Environment(\.markdownFont) private var font
    @Environment(\.colorScheme) private var colorScheme
    @State private var attributedCode: AttributedString?
    
    private var id: String {
        "\(colorScheme) mode: " + (language ?? "No Language Name") + code
    }

    var body: some View {
        Group {
            if let attributedCode {
                SwiftUI.Text(attributedCode)
            } else {
                SwiftUI.Text(code)
            }
        }
        .task(id: id, highlight)
        .lineSpacing(5)
        .font(font.codeBlock)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
        .overlay(alignment: .bottomTrailing) {
            if let language {
                SwiftUI.Text(language.uppercased())
                    .font(.callout)
                    .padding(8)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @Sendable private func highlight() {
        guard let highlighter = Highlightr.shared else { return }
        highlighter.setTheme(to: colorScheme == .dark ? theme.darkModeThemeName : theme.lightModeThemeName)
        let language = highlighter.supportedLanguages().first(where: { $0.lowercased() == self.language?.lowercased() })
        if let highlightedCode = highlighter.highlight(code, as: language) {
            withAnimation {
                attributedCode = AttributedString(highlightedCode)
            }
        }
    }
}

extension Highlightr {
    static var shared: Highlightr? = Highlightr()
}
#endif
