import Foundation

struct RendererConfiguration {
    var imageHandlerConfiguration: ImageHandlerConfiguration
    var directiveBlockConfiguration: DirectiveBlockConfiguration
    var lazyLoad: Bool
}

extension MarkdownView {
    var configuration: RendererConfiguration {
        RendererConfiguration(
            imageHandlerConfiguration: imageHandlerConfiguration,
            directiveBlockConfiguration: directiveBlockConfiguration,
            lazyLoad: lazyLoad
        )
    }
}
