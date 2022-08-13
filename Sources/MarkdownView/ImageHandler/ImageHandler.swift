import SwiftUI

public struct MarkdownImageHandler {
    typealias SwiftUIImage = SwiftUI.Image
    var image: (URL, String) -> any View
    
    public init(@ViewBuilder image: @escaping (URL, String) -> some View) {
        self.image = image
    }
}

extension MarkdownImageHandler {
    public static var networkImage = MarkdownImageHandler { 
        NetworkImage(url: $0, alt: $1)
    }
    
    public static func relativePathImage(
        baseURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    ) -> MarkdownImageHandler {
        MarkdownImageHandler {
            let url = baseURL.appendingPathComponent($0.absoluteString)
            NetworkImage(url: url, alt: $1)
        }
    }
}

class ImageHandlerConfiguration {
    var baseURL: URL
    
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
