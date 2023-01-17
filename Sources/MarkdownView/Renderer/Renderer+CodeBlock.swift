import Markdown
import SwiftUI
import Highlightr

// MARK: - Inline Code Block
extension Renderer {
    mutating func visitInlineCode(_ inlineCode: InlineCode) -> AnyView {
        AnyView(InlineCodeView(code: inlineCode.code))
    }
    
    func visitInlineHTML(_ inlineHTML: InlineHTML) -> AnyView {
        AnyView(SwiftUI.Text(inlineHTML.rawHTML))
    }
}

struct InlineCodeView: View {
    var code: String
    @State private var subText = [String]()
    
    var body: some View {
        Group {
            if subText.isEmpty != code.isEmpty {
                // An invisible placeholder which is
                // used to let SwiftUI execute `updateContent`
                Color.black.opacity(0.001)
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
        .task(id: code, updateContent)
    }
    
    @Sendable func updateContent() {
        subText = Renderer.Split(code)
    }
}

// MARK: - Code Block

extension Renderer {
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> AnyView {
        AnyView(
            HighlightedCodeBlock(
                language: codeBlock.language,
                code: codeBlock.code,
                theme: configuration.codeBlockTheme
            )
        )
    }
    
    func visitHTMLBlock(_ html: HTMLBlock) -> AnyView {
        AnyView(SwiftUI.Text(html.rawHTML))
    }
}

struct HighlightedCodeBlock: View {
    var language: String?
    var code: String
    var theme: CodeBlockTheme
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var attributedCode: AttributedString?
    
    var highlighter: Highlightr? = Highlightr()
    private var id: String { (language ?? "No Language Name") + code }

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
        .drawingGroup()
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
        let language = highlighter.supportedLanguages().first(where: { $0.lowercased() == self.language })
        if let highlightedCode = highlighter.highlight(code, as: language) {
            attributedCode = AttributedString(highlightedCode)
        }
    }
}

/// The configuration for code blocks.
///
/// - note: For more information, Check out [raspu/Highlightr](https://github.com/raspu/Highlightr) .
public struct CodeBlockTheme: Equatable {
    /// The theme name in Light Mode.
    var lightModeThemeName: String
    
    /// The theme name in Dark Mode.
    var darkModeThemeName: String
    
    /// Creates a single theme for the Code Block.
    ///
    /// - Parameter themeName: the name of the theme to use in both Light Mode and Dark Mode.
    ///
    /// - warning: You should test the visibility of the code in Light Mode and Dark Mode first.
    public init(themeName: String) {
        lightModeThemeName = themeName
        darkModeThemeName = themeName
    }
    
    /// Creates a combination of two themes that will perfectly adapt both Light Mode and Dark Mode.
    ///
    /// - Parameters:
    ///   - lightModeThemeName: the name of the theme to use in Light Mode.
    ///   - darkModeThemeName: the name of the theme to use in Dark Mode.
    ///
    ///  If you want to use the same theme on both Dark Mode and Light Mode,
    ///  you should use ``init(themeName:)``.
    public init(lightModeThemeName: String, darkModeThemeName: String) {
        self.lightModeThemeName = lightModeThemeName
        self.darkModeThemeName = darkModeThemeName
    }
}
