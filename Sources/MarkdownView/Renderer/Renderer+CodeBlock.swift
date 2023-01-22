import Markdown
import SwiftUI
import Highlightr

// MARK: - Inline Code Block
extension Renderer {
    mutating func visitInlineCode(_ inlineCode: InlineCode) -> Result {
        var attributedString = AttributedString(stringLiteral: inlineCode.code)
        attributedString.foregroundColor = configuration.tintColor
        attributedString.backgroundColor = configuration.tintColor.opacity(0.1)
        return Result(SwiftUI.Text(attributedString))
    }
    
    func visitInlineHTML(_ inlineHTML: InlineHTML) -> Result {
        Result(SwiftUI.Text(inlineHTML.rawHTML))
    }
}

// MARK: Deprecated
struct InlineCodeView: View {
    var code: String
    @State private var subText = [String]()
    
    var body: some View {
        Group {
            if subText.isEmpty != code.isEmpty {
                // An invisible placeholder which is
                // used to let SwiftUI execute `updateContent`
                SwiftUI.Text(code)
            } else {
                ForEach(subText.indices, id: \.self) { index in
                    let roundedSide: WithRoundedCorner.Side = {
                        if subText.count == 1 { return .bothSides }
                        if index == 0 { return .leading }
                        else if index == subText.count - 1 { return .trailing }
                        return .none
                    }()
                    let additionalSpace: CGFloat = {
                        if roundedSide == .none { return 0 }
                        else if roundedSide == .bothSides { return 10 }
                        return 5
                    }()
                    let blockBackground = GeometryReader { proxy in
                        let size = proxy.size
                        Rectangle()
                            .fill(.tint.opacity(0.1))
                            .frame(width: size.width + additionalSpace,
                                   height: size.height + 5)
                            .withCornerRadius(5, at: roundedSide)
                            .offset(x: roundedSide == .leading || roundedSide == .bothSides ? -5 : 0,
                                    y: -2.5)
                    }
                    SwiftUI.Text(subText[index])
                        .font(.system(.subheadline, design: .monospaced).bold())
                        .background { blockBackground }
                        .foregroundStyle(.tint)
                        .padding(.vertical, 2.5)
                        // avoid integrating with the block above.
                        .padding(.top, 1)
                        .padding(roundedSide.edge, roundedSide == .none ? 0 : 5)
                }
            }
        }
        .task(id: code) {
            Task.detached {
                // await self.updateContent()
            }
        }
    }
    
    // Deprecated
//    func updateContent() async {
//        let splittedText = await RendererProcessor.main.splitText(code)
//        await MainActor.run {
//            subText = splittedText
//        }
//    }
}

// MARK: - Code Block

extension Renderer {
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> Result {
        Result {
            HighlightedCodeBlock(
                language: codeBlock.language,
                code: codeBlock.code,
                theme: configuration.codeBlockTheme
            )
        }
    }
    
    func visitHTMLBlock(_ html: HTMLBlock) -> Result {
        // Forced conversion of text to view
        Result { SwiftUI.Text(html.rawHTML) }
    }
}

struct HighlightedCodeBlock: View {
    var language: String?
    var code: String
    var theme: CodeBlockTheme
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var attributedCode: AttributedString?
    
    var highlighter: Highlightr? = Highlightr()
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
        .font(.system(.callout, design: .monospaced))
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
        guard let highlighter else { return }
        highlighter.setTheme(to: colorScheme == .dark ? theme.darkModeThemeName : theme.lightModeThemeName)
        let language = highlighter.supportedLanguages().first(where: { $0.lowercased() == self.language?.lowercased() })
        if let highlightedCode = highlighter.highlight(code, as: language) {
            withAnimation {
                attributedCode = AttributedString(highlightedCode)
            }
        }
    }
}
