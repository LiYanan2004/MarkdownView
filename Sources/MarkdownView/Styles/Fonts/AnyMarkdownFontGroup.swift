import SwiftUI

/// A type-erased `MarkdownFontGroup` value.
public struct AnyMarkdownFontGroup: Sendable {
    var _h1: any CustomCTFontConvertible
    var _h2: any CustomCTFontConvertible
    var _h3: any CustomCTFontConvertible
    var _h4: any CustomCTFontConvertible
    var _h5: any CustomCTFontConvertible
    var _h6: any CustomCTFontConvertible
    var _codeBlock: any CustomCTFontConvertible
    var _blockQuote: any CustomCTFontConvertible
    var _tableHeader: any CustomCTFontConvertible
    var _tableBody: any CustomCTFontConvertible
    var _body: any CustomCTFontConvertible
    var _inlineMath: any CustomCTFontConvertible
    var _displayMath: any CustomCTFontConvertible
    
    init(_ group: some MarkdownFontGroup) {
        _h1 = group.h1
        _h2 = group.h2
        _h3 = group.h3
        _h4 = group.h4
        _h5 = group.h5
        _h6 = group.h6
        _codeBlock = group.codeBlock
        _blockQuote = group.blockQuote
        _tableHeader = group.tableHeader
        _tableBody = group.tableBody
        _body = group.body
        _inlineMath = group.inlineMath
        _displayMath = group.displayMath
    }
}

extension AnyMarkdownFontGroup: MarkdownFontGroup {
    /// The erased font used for level-one headings.
    public var h1: any CustomCTFontConvertible { _h1 }

    /// The erased font used for level-two headings.
    public var h2: any CustomCTFontConvertible { _h2 }

    /// The erased font used for level-three headings.
    public var h3: any CustomCTFontConvertible { _h3 }

    /// The erased font used for level-four headings.
    public var h4: any CustomCTFontConvertible { _h4 }

    /// The erased font used for level-five headings.
    public var h5: any CustomCTFontConvertible { _h5 }

    /// The erased font used for level-six headings.
    public var h6: any CustomCTFontConvertible { _h6 }

    /// The erased font used for fenced code blocks.
    public var codeBlock: any CustomCTFontConvertible { _codeBlock }

    /// The erased font used for block quotes.
    public var blockQuote: any CustomCTFontConvertible { _blockQuote }

    /// The erased font used for table header cells.
    public var tableHeader: any CustomCTFontConvertible { _tableHeader }

    /// The erased font used for table body cells.
    public var tableBody: any CustomCTFontConvertible { _tableBody }

    /// The erased font used for body text.
    public var body: any CustomCTFontConvertible { _body }

    /// The erased font used for inline math.
    public var inlineMath: any CustomCTFontConvertible { _inlineMath }

    /// The erased font used for display math.
    public var displayMath: any CustomCTFontConvertible { _displayMath }
}
