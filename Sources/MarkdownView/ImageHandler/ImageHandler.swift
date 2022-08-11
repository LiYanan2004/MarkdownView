import SwiftUI

public struct MarkdownImageHandler {
    typealias SwiftUIImage = SwiftUI.Image
    var image: (URL) -> any View
    
    public init(@ViewBuilder image: @escaping (URL) -> some View) {
        self.image = image
    }
}

extension MarkdownImageHandler {
    public static var networkImage = MarkdownImageHandler {
        NetworkImage(url: $0)
    }
    
    public static func storageImage(
        baseURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    ) -> MarkdownImageHandler {
        MarkdownImageHandler { url in
            let url = baseURL.appendingPathComponent(url.absoluteString)
            LocalImage(url: url)
        }
    }
}

class ImageHandlerConfiguration {
    var baseURL:URL
    
    init(baseURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]) {
        self.baseURL = baseURL
    }
    
    var imageHandlers: [String: MarkdownImageHandler] = [
        "http": .networkImage,
        "https": .networkImage,
    ]
    
    func addHandler(
        _ handler: MarkdownImageHandler, forURLScheme urlScheme: String
    ) {
        self.imageHandlers[urlScheme] = handler
    }
}
