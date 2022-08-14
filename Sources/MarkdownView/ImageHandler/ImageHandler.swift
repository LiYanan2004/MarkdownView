import SwiftUI

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
            if let uiImage = Image(uiImage: UIImage(named: name(url), in: bundle, compatibleWith: nil)) {
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
