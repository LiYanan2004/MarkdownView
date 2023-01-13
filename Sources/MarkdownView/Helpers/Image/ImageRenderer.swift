import SwiftUI

class ImageRenderer {
    /// The base URL for local images or network images.
    var baseURL: URL
    
    /// Create a Configuration for image handling.
    init(baseURL: URL = .documentsDirectory) {
        self.baseURL = baseURL
    }
    
    /// All the handlers that have been added.
    var imageHandlers: [String: any ImageDisplayable] = [
        "http": NetworkImageDisplayable(),
        "https": NetworkImageDisplayable(),
    ]
    
    /// Add custom handler for Image Handling.
    /// - Parameters:
    ///   - handler: Represention of the Image.
    ///   - urlScheme: The url scheme to use the handler.
    func addHandler(
        _ handler: some ImageDisplayable, forURLScheme urlScheme: String
    ) {
        self.imageHandlers[urlScheme] = handler
    }
    
    func loadImage(
        handler: (any ImageDisplayable)?, url: URL, alt: String?
    ) -> AnyView {
        if let handler {
            // Found a specific handler.
            return AnyView(handler.makeImage(url: url, alt: alt))
        } else {
            // No specific handler.
            // Try to load the image from the Base URL.
            return AnyView(RelativePathImageDisplayable(baseURL: baseURL).makeImage(url: url, alt: alt))
        }
    }
}
