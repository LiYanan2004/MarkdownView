import SwiftUI

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
    
    public init(h1: SwiftUI.Font = Font.largeTitle, h2: SwiftUI.Font = Font.title, h3: SwiftUI.Font = Font.title2, h4: SwiftUI.Font = Font.title3, h5: SwiftUI.Font = Font.headline, h6: SwiftUI.Font = Font.headline.weight(.regular), body: SwiftUI.Font = Font.body, codeBlock: SwiftUI.Font = Font.system(.callout, design: .monospaced), blockQuote: SwiftUI.Font = Font.system(.body, design: .serif), tableHeader: SwiftUI.Font = Font.headline, tableBody: SwiftUI.Font = Font.body) {
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
    
    public enum TextType: Equatable {
        case h1,h2,h3,h4,h5,h6
        case body
        case codeBlock,blockQuote
        case tableHeader,tableBody
    }
}

extension MarkdownFontProvider: Equatable {}

extension MarkdownFontProvider: EnvironmentKey {
    public static var defaultValue = MarkdownFontProvider()
}

public extension EnvironmentValues {
    var markdownFont: MarkdownFontProvider {
        get { self[MarkdownFontProvider.self] }
        set { self[MarkdownFontProvider.self] = newValue }
    }
}

public extension View {
     func font(for type: MarkdownFontProvider.TextType, font: Font) -> some View {
        transformEnvironment(\.markdownFont) { view in
            view.modify(type, font: font)
        }
    }
    
    func markdownFont(_ fontProvider: MarkdownFontProvider) -> some View {
        environment(\.markdownFont, fontProvider)
    }
}
