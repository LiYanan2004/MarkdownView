import Foundation

struct RendererConfiguration {
    var imageHandlerConfiguration: ImageHandlerConfiguration
    var directiveBlockConfiguration: DirectiveBlockConfiguration
    var imageCacheController: ImageCacheController
    var codeBlockThemeConfiguration: CodeBlockThemeConfiguration
    
}

extension MarkdownView {
    var configuration: RendererConfiguration {
        RendererConfiguration(
            imageHandlerConfiguration: imageHandlerConfiguration,
            directiveBlockConfiguration: directiveBlockConfiguration,
            imageCacheController: imageCacheController,
            codeBlockThemeConfiguration: codeBlockThemeConfiguration
        )
    }
}
