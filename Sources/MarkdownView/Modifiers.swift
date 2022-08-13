import SwiftUI

// MARK: - Content Loading
extension MarkdownView {
    public func lazyLoading(_ lazyLoadingEnabled: Bool) -> MarkdownView {
        var result = self
        result.lazyLoad = lazyLoadingEnabled
        
        return result
    }
}

// MARK: - Styles
extension MarkdownView {
    
}

// MARK: - Image Handler
extension MarkdownView {
    public func imageHandler(
        _ handler: MarkdownImageHandler, forURLScheme urlScheme: String
    ) -> MarkdownView {
        let result = self
        result.imageHandlerConfiguration.addHandler(handler, forURLScheme: urlScheme)
        
        return result
    }
}
