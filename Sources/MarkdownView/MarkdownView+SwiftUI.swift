import SwiftUI

// MARK: - Display Images
extension MarkdownView {
    /// Adds a built-in handler to render images.
    ///
    /// Built-in handlers helps you quickly add image rendering from your assets or from a relative path.
    ///
    /// - parameters
    ///     - handler: One of built-in handlers.
    ///     - urlScheme: A scheme for the renderer to determine when to use the handler.
    /// - Returns: A `MarkdownView` that can render the image with a specific scheme.
    ///
    /// You can set this handler multiple times if you want to add multiple schemes.
    public func imageHandler(
        _ handler: BuiltInImageHandler, forURLScheme urlScheme: String
    ) -> MarkdownView {
        let result = self
        result.imageRenderer.addHandler(handler.displayable, forURLScheme: urlScheme)

        return result
    }
    
    /// Adds your own handlers to render images.
    ///
    /// - parameters
    ///     - handler: The handler you created to handle image loading and displaying.
    ///     - urlScheme: A scheme for the renderer to determine when to use the handler.
    /// - Returns: A `MarkdownView` that can render the image with a specific scheme.
    ///
    /// You can set this handler multiple times if you want to add multiple schemes.
    public func imageHandler(
        _ handler: some ImageDisplayable, forURLScheme urlScheme: String
    ) -> MarkdownView {
        let result = self
        result.imageRenderer.addHandler(handler, forURLScheme: urlScheme)

        return result
    }
}

// MARK: - Display Directive Blocks
extension MarkdownView {
    /// Adds your custom block directive handler.
    ///
    /// - parameters:
    ///     - handler: the handler you have created to handle block displaying.
    ///     - name: specify which kind of Directive Block will use your own handler.
    /// - Returns: `MarkdownView` with custom directive block loading behavior.
    ///
    /// You can set this handler multiple times if you have multiple handlers.
    public func blockDirectiveHandler(
        _ handler: some BlockDirectiveDisplayable, for name: String
    ) -> MarkdownView {
        let result = self
        result.blockDirectiveRenderer.addHandler(handler, for: name)
        
        return result
    }
}

// MARK: - Code Block Theme
extension MarkdownView {
    /// Sets the theme of the Code Blocks.
    /// 
    /// - Parameter configuration: Theme configuration of the Code Block, see ``CodeBlockThemeConfiguration``.
    /// - Returns: `MarkdownView` with custom Code Block theme.
    public func codeBlockThemeConfiguration(
        using configuration: CodeBlockThemeConfiguration
    ) -> MarkdownView {
        var result = self
        result.codeBlockThemeConfiguration = configuration
        
        return result
    }
}

// MARK: - MarkdownView Role
extension MarkdownView {
    ///  Configures the role of the markdown text.
    /// - Parameter role: A role to tell MarkdownView how to render its content.
    /// - Returns: A rendered MarkdownView using the role you specified.
    public func markdownViewRole(_ role: MarkdownViewRole) -> MarkdownView {
        var result = self
        result.role = role
        
        return result
    }
    
    public enum MarkdownViewRole {
        /// The normal role.
        ///
        /// A role that makes the view take the space it needs, like a normal SwiftUI View.
        case normal
        /// The editor role.
        ///
        /// A role that makes the view take the maximum space
        /// and align its content in the top-leading, just like an editor.
        ///
        /// A Markdown Editor typically use this mode to provide a Live Preview.
        case editor
    }
}
