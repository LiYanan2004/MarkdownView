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
    public var h1: any CustomCTFontConvertible { _h1 }
    public var h2: any CustomCTFontConvertible { _h2 }
    public var h3: any CustomCTFontConvertible { _h3 }
    public var h4: any CustomCTFontConvertible { _h4 }
    public var h5: any CustomCTFontConvertible { _h5 }
    public var h6: any CustomCTFontConvertible { _h6 }
    public var codeBlock: any CustomCTFontConvertible { _codeBlock }
    public var blockQuote: any CustomCTFontConvertible { _blockQuote }
    public var tableHeader: any CustomCTFontConvertible { _tableHeader }
    public var tableBody: any CustomCTFontConvertible { _tableBody }
    public var body: any CustomCTFontConvertible { _body }
    public var inlineMath: any CustomCTFontConvertible { _inlineMath }
    public var displayMath: any CustomCTFontConvertible { _displayMath }
}
