import Markdown
import SwiftUI
import Highlightr

// MARK: - Inline Code Block
extension Renderer {
    mutating func visitInlineCode(_ inlineCode: InlineCode) -> AnyView {
        var subText = [SwiftUI.Text]()
        
        Split(inlineCode.code).forEach {
            subText.append(SwiftUI.Text($0))
        }

        return AnyView(ForEach(subText.indices, id: \.self) { index in
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
            let blockBackground: GeometryReader = {
                GeometryReader { proxy in
                    let size = proxy.size
                    Rectangle()
                        .fill(.tint.opacity(0.2))
                        .frame(width: size.width + additionalSpace,
                               height: size.height + 5)
                        .withCornerRadius(5, at: roundedSide)
                        .offset(x: roundedSide == .leading || roundedSide == .bothSides ? -5 : 0,
                                y: -2.5)
                }
            }()
            
            subText[index]
                .font(.system(.body, design: .monospaced).bold())
                .background { blockBackground }
                .foregroundStyle(.tint)
                .padding(.vertical, 8)
                .padding(roundedSide.edge, roundedSide == .none ? 0 : 5)
        })
    }
}

// MARK: - Code Block

extension Renderer {
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> AnyView {
        return AnyView(VStack(alignment: .trailing, spacing: 0) {
            Group {
                if let highlighter = Highlightr(), let language = codeBlock.language {
                    HighlightCodeBlock(
                        highlighter: highlighter,
                        language: language,
                        code: codeBlock.code,
                        themeConfiguration: configuration.codeBlockThemeConfiguration)
                } else {
                    SwiftUI.Text(codeBlock.code)
                }
            }
            .font(.system(.callout, design: .monospaced))
            .drawingGroup()
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
            .overlay(alignment: .bottomTrailing) {
                if let language = codeBlock.language {
                    SwiftUI.Text(language)
                        .font(.caption)
                        .padding(8)
                        .foregroundStyle(.secondary)
                }
            }
            
            PaddingLine()
        })
    }
}


struct HighlightCodeBlock: View {
    var highlighter: Highlightr
    var language: String
    var code: String
    var themeConfiguration: CodeBlockThemeConfiguration
    @Environment(\.colorScheme) private var colorScheme
    
    var highlightedCode: NSAttributedString? {
        highlighter.setTheme(to: colorScheme == .dark ? themeConfiguration.darkModeThemeName : themeConfiguration.lightModeThemeName)
        return highlighter.highlight(code, as: language)
    }
    
    var body: some View {
        if let highlightedCode = highlightedCode {
            let attributedString = AttributedString(highlightedCode)
            Text(attributedString)
        }
    }
}

/// The Theme Configuration of the Code Block
///
/// - note: **Available theme names are**: "vs", "atelier-seaside-dark", "isbl-editor-dark", "brown-paper", "atelier-plateau-light", "school-book", "xcode", "atelier-sulphurpool-dark", "tomorrow-night-blue", "vs2015", "atelier-heath-dark", "paraiso-light", "rainbow", "qtcreator\_light", "a11y-light", "kimbie.dark", "atelier-heath-light", "far", "atelier-dune-dark", "shades-of-purple", "kimbie.light", "railscasts", "solarized-dark", "atelier-estuary-light", "xt256", "mono-blue", "ocean", "github-gist", "atelier-seaside-light", "tomorrow-night-eighties", "atom-one-dark", "qtcreator\_dark", "atelier-savanna-dark", "color-brewer", "pojoaque", "routeros", "atelier-forest-dark", "gml", "tomorrow-night", "obsidian", "lightfair", "atelier-lakeside-dark", "gruvbox-light", "idea", "tomorrow", "atelier-forest-light", "arduino-light", "gruvbox-dark", "dracula", "magula", "arta", "purebasic", "hopscotch", "github", "nord", "dark", "atom-one-light", "monokai", "docco", "default", "ascetic", "isbl-editor-light", "atelier-cave-light", "a11y-dark", "atelier-sulphurpool-light", "atelier-plateau-dark", "darkula", "atelier-cave-dark", "ir-black", "solarized-light", "tomorrow-night-bright", "atelier-savanna-light", "foundation", "codepen-embed", "atelier-estuary-dark", "googlecode", "atom-one-dark-reasonable", "atelier-dune-light", "paraiso-dark", "zenburn", "androidstudio", "grayscale", "sunburst", "agate", "hybrid", "darcula", "atelier-lakeside-light", "monokai-sublime", "an-old-hope"
///
/// For more information, Check out [raspu/Highlightr](https://github.com/raspu/Highlightr)
public struct CodeBlockThemeConfiguration {
    /// The theme name in Light Mode
    public var lightModeThemeName: String
    
    /// The theme name in Dark Mode
    public var darkModeThemeName: String
    
    /// Creates a single theme for the Code Block
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
    ///  you should use ``CodeBlockThemeConfiguration/init(themeName:)``.
    public init(lightModeThemeName: String, darkModeThemeName: String) {
        self.lightModeThemeName = lightModeThemeName
        self.darkModeThemeName = darkModeThemeName
    }
}
