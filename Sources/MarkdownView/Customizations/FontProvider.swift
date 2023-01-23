import SwiftUI

/// A font provider that defines fonts for each type of components.
public struct MarkdownFontProvider {
    // Headings
    var h1 = Font.largeTitle
    var h2 = Font.title
    var h3 = Font.title2
    var h4 = Font.title3
    var h5 = Font.headline
    var h6 = Font.headline.weight(.regular)
    
    // Normal text
    var body = Font.body
    
    // Blocks
    var codeBlock = Font.system(.callout, design: .monospaced)
    var blockQuote = Font.system(.body, design: .serif)
    
    // Tables
    var tableHeader = Font.headline
    var tableBody = Font.body
    
    /// Create a font set for MarkdownView to apply to components.
    /// - Parameters:
    ///   - h1: The font for H1.
    ///   - h2: The font for H2.
    ///   - h3: The font for H3.
    ///   - h4: The font for H4.
    ///   - h5: The font for H5.
    ///   - h6: The font for H6.
    ///   - body: The font for body. (normal text)
    ///   - codeBlock: The font for code blocks.
    ///   - blockQuote: The font for block quotes.
    ///   - tableHeader: The font for headers of tables.
    ///   - tableBody: The font for bodies of tables.
    public init(h1: Font = Font.largeTitle, h2: Font = Font.title, h3: Font = Font.title2, h4: Font = Font.title3, h5: Font = Font.headline, h6: Font = Font.headline.weight(.regular), body: Font = Font.body, codeBlock: Font = Font.system(.callout, design: .monospaced), blockQuote: Font = Font.system(.body, design: .serif), tableHeader: Font = Font.headline, tableBody: Font = Font.body) {
        self.h1 = h1
        self.h2 = h2
        self.h3 = h3
        self.h4 = h4
        self.h5 = h5
        self.h6 = h6
        self.body = body
        self.codeBlock = codeBlock
        self.blockQuote = blockQuote
        self.tableHeader = tableHeader
        self.tableBody = tableBody
    }
}

extension MarkdownFontProvider {
    mutating func modify(_ type: TextType, font: Font) {
        switch type {
        case .h1: h1 = font
        case .h2: h2 = font
        case .h3: h3 = font
        case .h4: h4 = font
        case .h5: h5 = font
        case .h6: h6 = font
        case .body: body = font
        case .blockQuote: blockQuote = font
        case .codeBlock: codeBlock = font
        case .tableBody: tableBody = font
        case .tableHeader: tableHeader = font
        }
    }
    
    /// The component type of text.
    public enum TextType: Equatable {
        case h1,h2,h3,h4,h5,h6
        case body
        case codeBlock,blockQuote
        case tableHeader,tableBody
    }
}

extension MarkdownFontProvider: Equatable {}

struct MarkdownFontProviderKey: EnvironmentKey {
    static var defaultValue = MarkdownFontProvider()
}

public extension EnvironmentValues {
    var markdownFont: MarkdownFontProvider {
        get { self[MarkdownFontProviderKey.self] }
        set { self[MarkdownFontProviderKey.self] = newValue }
    }
}

public extension View {
    /// Sets the font for the specific component in MarkdownView.
    /// - Parameters:
    ///   - font: The font to apply to these components.
    ///   - type: The type of components to apply the font.
    func font(_ font: Font, for type: MarkdownFontProvider.TextType) -> some View {
        transformEnvironment(\.markdownFont) { view in
            view.modify(type, font: font)
        }
    }
    
    /// Apply a font set to MarkdownView.
    ///
    /// This is useful when you want to completely customize fonts.
    /// 
    /// - Parameter fontProvider: A font set to apply to the MarkdownView.
    func markdownFont(_ fontProvider: MarkdownFontProvider) -> some View {
        environment(\.markdownFont, fontProvider)
    }
}
