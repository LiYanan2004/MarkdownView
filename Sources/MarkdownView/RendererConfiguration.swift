import Foundation

struct RendererConfiguration {
    var lazyLoad: Bool
    var imageHandlerConfiguration: ImageHandlerConfiguration
    var directiveBlockConfiguration: DirectiveBlockConfiguration
    var imageCacheController: ImageCacheController
    var codeBlockThemeConfiguration: CodeBlockThemeConfiguration
    
}

extension MarkdownView {
    var configuration: RendererConfiguration {
        RendererConfiguration(
            lazyLoad: lazyLoad,
            imageHandlerConfiguration: imageHandlerConfiguration,
            directiveBlockConfiguration: directiveBlockConfiguration,
            imageCacheController: imageCacheController,
            codeBlockThemeConfiguration: codeBlockThemeConfiguration
        )
    }
}
