import SwiftUI

/// A type that applies foreground style group to all MarkdownViews within a view hierarchy.
///
/// To configure the current foreground style group for a view hierarchy, use the foregroundGroup(_:) modifier. Specify a style group that conforms to MarkdownForegroundStyleGroup when creating a MarkdownVIew.
public protocol MarkdownForegroundStyleGroup {
    // Headings
    associatedtype H1Style: ShapeStyle
    associatedtype H2Style: ShapeStyle
    associatedtype H3Style: ShapeStyle
    associatedtype H4Style: ShapeStyle
    associatedtype H5Style: ShapeStyle
    associatedtype H6Style: ShapeStyle
    
    var h1: H1Style { get }
    var h2: H2Style { get }
    var h3: H3Style { get }
    var h4: H4Style { get }
    var h5: H5Style { get }
    var h6: H6Style { get }
    
    // Blocks
    associatedtype CodeBlockStyle: ShapeStyle
    associatedtype BlockQuoteStyle: ShapeStyle
    
    @available(*, deprecated, message: "This style will take no effect in current release and will be removed in the future. Implement a custom `CodeBlockStyle` instead.")
    var codeBlock: CodeBlockStyle { get }
    @available(*, deprecated, message: "This style will take no effect in current release and will be removed in the future. Implement a custom `BlockQuoteStyle` instead.")
    var blockQuote: BlockQuoteStyle { get }
    
    // Tables
    associatedtype TableHeaderStyle: ShapeStyle
    associatedtype TableBodyStyle: ShapeStyle
    
    @available(*, deprecated, message: "This style will take no effect in current release and will be removed in the future. Implement a custom `MarkdownTableStyle` instead.")
    var tableHeader: TableHeaderStyle { get }
    @available(*, deprecated, message: "This style will take no effect in current release and will be removed in the future. Implement a custom `MarkdownTableStyle` instead.")
    var tableBody: TableBodyStyle { get }
}

extension MarkdownForegroundStyleGroup {
    // Headings
    public var h1: some ShapeStyle { .foreground }
    public var h2: some ShapeStyle { .foreground }
    public var h3: some ShapeStyle { .foreground }
    public var h4: some ShapeStyle { .foreground }
    public var h5: some ShapeStyle { .foreground }
    public var h6: some ShapeStyle { .foreground }
    
    // Blocks
    public var codeBlock: some ShapeStyle { .foreground }
    public var blockQuote: some ShapeStyle { .foreground }
    
    // Tables
    public var tableHeader: some ShapeStyle { .foreground }
    public var tableBody: some ShapeStyle { .foreground }
}
