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
        ImageRenderer.shared.addHandler(handler.displayable, forURLScheme: urlScheme)
        return self
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
        ImageRenderer.shared.addHandler(handler, forURLScheme: urlScheme)
        return self
    }
}

// MARK: - Display Directive Blocks

extension MarkdownView {
    /// Adds your custom block directive handler.
    ///
    /// - parameters:
    ///     - handler: The handler you have created to handle block displaying.
    ///     - name: The name of the  block directive.
    /// - Returns: `MarkdownView` with custom directive block loading behavior.
    ///
    /// You can set this handler multiple times if you have multiple handlers.
    public func blockDirectiveHandler(
        _ handler: some BlockDirectiveDisplayable, for name: String
    ) -> MarkdownView {
        BlockDirectiveRenderer.shared.addHandler(handler, for: name)
        return self
    }
}

// MARK: - Code Blocks

extension MarkdownView {
    /// Sets the theme of code blocks.
    /// 
    /// - Parameter theme: Theme configuration of the code block, see ``CodeBlockTheme``.
    /// - Returns: `MarkdownView` with custom code block theme.
    public func codeBlockTheme(_ theme: CodeBlockTheme) -> MarkdownView {
        var result = self
        result.codeBlockTheme = theme
        return result
    }
    
    /// Sets the tint color for inline blocks.
    ///
    /// - Parameter color: The tint Color to apply.
    public func inlineCodeBlockTint(_ color: Color) -> MarkdownView {
        var result = self
        result.tintColor = color
        return result
    }
}

// MARK: - MarkdownView Role

extension MarkdownView {
    ///  Configures the role of the markdown view.
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
