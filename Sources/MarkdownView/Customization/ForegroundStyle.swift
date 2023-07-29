import SwiftUI

class _MDForegroundStyleManager {
    static var shared = _MDForegroundStyleManager()
    
    var provider = MarkdownForegroundStyleProvider()
}

/// Foreground style provider that defines styles for each type of components.
public struct MarkdownForegroundStyleProvider: Identifiable {
    
    static var defaultForegroundStyle = AnyShapeStyle(.foreground)
    
    /// A stable ID of the provider.
    ///
    /// This value will be updated when any of the style changes.
    public var id = UUID()
    
    // Headings
    var h1 = defaultForegroundStyle
    var h2 = defaultForegroundStyle
    var h3 = defaultForegroundStyle
    var h4 = defaultForegroundStyle
    var h5 = defaultForegroundStyle
    var h6 = defaultForegroundStyle
    
    // Blocks
    var codeBlock = defaultForegroundStyle
    var blockQuote = defaultForegroundStyle
    
    // Tables
    var tableHeader = defaultForegroundStyle
    var tableBody = defaultForegroundStyle
    
    /// Create a foreground style set for MarkdownView to apply to components.
    /// - Parameters:
    ///   - h1: The foreground for H1.
    ///   - h2: The foreground for H2.
    ///   - h3: The foreground for H3.
    ///   - h4: The foreground for H4.
    ///   - h5: The foreground for H5.
    ///   - h6: The foreground for H6.
    ///   - body: The foreground for body. (normal text)
    ///   - codeBlock: The foreground for code blocks.
    ///   - blockQuote: The foreground for block quotes.
    ///   - tableHeader: The foreground for headers of tables.
    ///   - tableBody: The foreground for bodies of tables.
    init(h1: AnyShapeStyle = defaultForegroundStyle, h2: AnyShapeStyle = defaultForegroundStyle, h3: AnyShapeStyle = defaultForegroundStyle, h4: AnyShapeStyle = defaultForegroundStyle, h5: AnyShapeStyle = defaultForegroundStyle, h6: AnyShapeStyle = defaultForegroundStyle, codeBlock: AnyShapeStyle = defaultForegroundStyle, blockQuote: AnyShapeStyle = defaultForegroundStyle, tableHeader: AnyShapeStyle = defaultForegroundStyle, tableBody: AnyShapeStyle = defaultForegroundStyle) {
        self.h1 = h1
        self.h2 = h2
        self.h3 = h3
        self.h4 = h4
        self.h5 = h5
        self.h6 = h6
        self.codeBlock = codeBlock
        self.blockQuote = blockQuote
        self.tableHeader = tableHeader
        self.tableBody = tableBody
    }
}

extension MarkdownForegroundStyleProvider {
    mutating func update<S: ShapeStyle>(_ component: Component, style: S, updateID: Bool) {
        let erasedShapeStyle = AnyShapeStyle(style)
        switch component {
        case .h1: h1 = erasedShapeStyle
        case .h2: h2 = erasedShapeStyle
        case .h3: h3 = erasedShapeStyle
        case .h4: h4 = erasedShapeStyle
        case .h5: h5 = erasedShapeStyle
        case .h6: h6 = erasedShapeStyle
        case .blockQuote: blockQuote = erasedShapeStyle
        case .codeBlock: codeBlock = erasedShapeStyle
        case .tableBody: tableBody = erasedShapeStyle
        case .tableHeader: tableHeader = erasedShapeStyle
        }
        
        if updateID {
            id = UUID()
        }
    }
    
    func value(of component: Self.Component) -> AnyShapeStyle {
        let keyPath: KeyPath<MarkdownForegroundStyleProvider, AnyShapeStyle>
        switch component {
        case .h1: keyPath = \.h1
        case .h2: keyPath = \.h2
        case .h3: keyPath = \.h3
        case .h4: keyPath = \.h4
        case .h5: keyPath = \.h5
        case .h6: keyPath = \.h6
        case .blockQuote: keyPath = \.blockQuote
        case .codeBlock: keyPath = \.codeBlock
        case .tableBody: keyPath = \.tableBody
        case .tableHeader: keyPath = \.tableHeader
        }
        return self[keyPath: keyPath]
    }
    
    /// The component type of text.
    public enum Component: Equatable {
        case h1,h2,h3,h4,h5,h6
        case codeBlock,blockQuote
        case tableHeader,tableBody
    }
}

extension MarkdownForegroundStyleProvider: Equatable {
    public static func == (lhs: MarkdownForegroundStyleProvider, rhs: MarkdownForegroundStyleProvider) -> Bool {
        // The ID are the same means they are exactly the same provider.
        return lhs.id == rhs.id
    }
}

// MARK: - Environment Values

struct MDForegroundStyleManagerKey: EnvironmentKey {
    static var defaultValue = _MDForegroundStyleManager.shared
}

extension EnvironmentValues {
    var foregroundStyleManager: _MDForegroundStyleManager {
        get { self[MDForegroundStyleManagerKey.self] }
        set { self[MDForegroundStyleManagerKey.self] = newValue }
    }
}

// MARK: - View Extension

public extension View {
    /// Apply a font set to MarkdownView.
    ///
    /// This is useful when you want to completely customize foreground styles.
    ///
    /// - Parameter foregroundStyleProvider: A style set to apply to the MarkdownView.
    func markdownForegroundStyle(_ foregroundStyleProvider: MarkdownForegroundStyleProvider) -> some View {
        transformEnvironment(\.foregroundStyleManager) { manager in
            manager.provider = foregroundStyleProvider
        }
    }
    
    /// Sets foreground style for the specific component in MarkdownView.
    /// 
    /// - Parameters:
    ///   - style: The style to apply to this type of components.
    ///   - component: The type of components to apply the foreground style.
    @ViewBuilder
    func foregroundStyle(_ style: some ShapeStyle, for component: MarkdownForegroundStyleProvider.Component) -> some View {
        transformEnvironment(\.foregroundStyleManager) { manager in
            let oldValue = manager.provider.value(of: component)
            let oldBuffer = withUnsafeBytes(of: oldValue) { $0 }
            let newBuffer = withUnsafeBytes(of: style) { $0 }
            
            // Update ID to re-render the content of MarkdownView.
            var needUpdateID = true
            // If we can identify there is no difference between the two,
            // we can significantly reduce unnecessary re-renderings to improve performance.
            if let oldPointer = oldBuffer.baseAddress,
               let newPointer = newBuffer.baseAddress {
                let oldBytes = Data(bytes: oldPointer, count: oldBuffer.count)
                let newBytes = Data(bytes: newPointer, count: newBuffer.count)
                // Compare the hash value of two data.
                // When `style` changes, the data changes.
                // Set `needUpdateID` to false if the two are the same, which means the style are the same.
                if oldBytes.hashValue == newBytes.hashValue {
                    needUpdateID = false
                }
            }
            
            manager.provider.update(component, style: style, updateID: needUpdateID)
        }
    }
}
