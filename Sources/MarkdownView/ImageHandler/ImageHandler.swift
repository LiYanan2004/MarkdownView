import SwiftUI

class ImageHandlerConfiguration {
    /// The base URL for local images or network images.
    var baseURL: URL
    
    /// Create a Configuration for image handling.
    init(baseURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]) {
        self.baseURL = baseURL
    }
    
    /// All the handlers that have been added.
    var imageHandlers: [String: MarkdownImageHandler] = [
        "http": .networkImage,
        "https": .networkImage,
    ]
    
    /// Add custom handler for Image Handling.
    /// - Parameters:
    ///   - handler: Represention of the Image.
    ///   - urlScheme: The url scheme to use the handler.
    func addHandler(
        _ handler: MarkdownImageHandler, forURLScheme urlScheme: String
    ) {
        self.imageHandlers[urlScheme] = handler
    }
}

/// Handle the represention of the Image.
public struct MarkdownImageHandler {
    typealias SwiftUIImage = SwiftUI.Image
    
    /// The Image View.
    var image: (URL, String) -> any View
    
    
    /// Create a Image Handler to handle image loading.
    /// - Parameter imageView: The Image View containing the image from a `URL` and a `String` as the title of the image.
    public init(@ViewBuilder imageView: @escaping (URL, String) -> some View) {
        self.image = imageView
    }
}

extension MarkdownImageHandler {
    /// A handler used to load Network Images.
    static var networkImage = MarkdownImageHandler {
        NetworkImage(url: $0, alt: $1)
    }
    
    /// A handler used to load Images in a relative path url.
    /// - note: You need to specify the `baseURL` when creating a `MarkdownView`
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
        MarkdownImageHandler { url, alt  in
#if os(macOS)
            let nsImage: NSImage?
            if let bundle = bundle, bundle != .main {
                nsImage = bundle.image(forResource: name(url))
            } else {
                nsImage = NSImage(named: name(url))
            }
            if let nsImage {
                return AnyView(VStack {
                    Image(nsImage: nsImage).resizable().aspectRatio(contentMode: .fit)
                    Text(alt).foregroundStyle(.secondary).font(.callout)
                })
            }
#elseif os(iOS) || os(tvOS)
            if let uiImage = UIImage(named: name(url), in: bundle, compatibleWith: nil) {
                return AnyView(VStack {
                    Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fit)
                    Text(alt).foregroundStyle(.secondary).font(.callout)
                })
            }
#endif
            return AnyView(VStack {
                Image(systemName: "externaldrive.fill.badge.xmark").font(.largeTitle)
                Text("Resource Error").font(.callout)
            }.foregroundStyle(.secondary))
        }
    }
}
