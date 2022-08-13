import SwiftUI

// MARK: - Content Loading
extension MarkdownView {
    /// Set the loading method.
    ///
    /// If you set `lazyLoadingEnabled` to false, it may increase memory usage.
    public func lazyLoading(_ lazyLoadingEnabled: Bool) -> MarkdownView {
        var result = self
        result.lazyLoad = lazyLoadingEnabled
        
        return result
    }
}

// MARK: - Styles
extension MarkdownView {
    
}

// MARK: - Image Handlers
extension MarkdownView {
    /// Set your custom Image Handler
    ///
    /// - parameter handler: the handler you have created to handle image loading and displaying.
    /// - parameter urlScheme: specify which kind of image will use your own handler
    ///
    /// You can set this handler multiple times if you have multiple handlers.
    public func imageHandler(
        _ handler: MarkdownImageHandler, forURLScheme urlScheme: String
    ) -> MarkdownView {
        let result = self
        result.imageHandlerConfiguration.addHandler(handler, forURLScheme: urlScheme)
        
        return result
    }
}

// MARK: - Custom Directive Blocks
extension MarkdownView {
    /// Set your custom Directive Block Handler
    ///
    /// - parameter handler: the handler you have created to handle block displaying.
    /// - parameter name: specify which kind of Directive Block will use your own handler
    ///
    /// You can set this handler multiple times if you have multiple handlers.
    public func directiveBlockHandler(
        _ handler: MarkdownDirectiveBlockHandler, for name: String
    ) -> MarkdownView {
        let result = self
        result.directiveBlockConfiguration.addHandler(handler, for: name)
        
        return result
    }
    
    /// Disable the default `@Background(background: _, textColor: _)` Directive Block.
    ///
    /// If your Directive Block's name conflicts with the default one, you can disable the default one.
    public func disableDefaultDirectiveBlockHandler() -> MarkdownView {
        let result = self
        result.directiveBlockConfiguration.directiveBlockHandlers = [:]
        
        return result
    }
}
