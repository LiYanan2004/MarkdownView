import SwiftUI

/// Handle the represention of the Image.
public struct MarkdownImageHandler {
    typealias SwiftUIImage = SwiftUI.Image
    
    /// The Image View.
    var image: (URL, String?) -> any View
    
    /// Create a Image Handler to handle image loading.
    /// - Parameter imageView: The Image View to display an image. The `imageView` closure's parameter contains the URL of the Image and an optional title of the Image.
    public init(@ViewBuilder imageView: @escaping (URL, String?) -> some View) {
        self.image = imageView
    }
}

extension MarkdownImageHandler {
    /// A handler used to load Network Images.
    static var networkImage = MarkdownImageHandler {
        NetworkImage(url: $0, alt: $1)
    }
    
    /// A handler used to load Images in a relative path url.
    ///
    /// - note: You need to specify the `baseURL` when creating a `MarkdownView`.
    public static func relativePathImage(
        baseURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    ) -> MarkdownImageHandler {
        MarkdownImageHandler {
            let url = baseURL.appendingPathComponent($0.absoluteString)
            NetworkImage(url: url, alt: $1)
        }
    }
    
    /// A handler used to load images from your Assets Catalog.
    public static func assetImage(
        name: @escaping (URL) -> String = \.lastPathComponent,
        in bundle: Bundle? = nil
    ) -> MarkdownImageHandler {
        MarkdownImageHandler { url, alt in
            #if os(macOS)
            let nsImage: NSImage?
            if let bundle = bundle, bundle != .main {
                nsImage = bundle.image(forResource: name(url))
            } else {
                nsImage = NSImage(named: name(url))
            }
            if let nsImage {
                return AssetImage(image: nsImage, alt: alt)
            }
            #elseif os(iOS) || os(tvOS)
            if let uiImage = UIImage(named: name(url), in: bundle, compatibleWith: nil) {
                return AssetImage(image: uiImage, alt: alt)
            }
            #endif
            return AssetImage(image: nil, alt: nil)
        }
    }
}
