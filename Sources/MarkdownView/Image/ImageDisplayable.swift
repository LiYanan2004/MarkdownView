import SwiftUI

public protocol ImageDisplayable {
    associatedtype ImageView: View
    
    /// Make the Image View.
    @ViewBuilder func makeImage(url: URL, alt: String?) -> ImageView
}

struct AnyImageDisplayable: ImageDisplayable {
    typealias ImageView = AnyView

    @ViewBuilder private let displayableClosure: (URL, String?) -> AnyView
    
    init<D: ImageDisplayable>(erasing imageDisplayable: D) {
        displayableClosure = { url, alt in
            AnyView(imageDisplayable.makeImage(url: url, alt: alt))
        }
    }

    func makeImage(url: URL, alt: String?) -> AnyView {
        displayableClosure(url, alt)
    }
}

// MARK: - Built-in handlers
/// Some Built-in handlers for developers to choose from.
public enum BuiltInImageHandler {
    
    /// Load Images from a relative path.
    case relativePathImage(url: URL)
    
    /// Load images from your Assets Catalog.
    case assetImage(name: (URL) -> String = \.lastPathComponent, bundle: Bundle? = nil)
    
    var displayable: some ImageDisplayable {
        switch self {
        case .relativePathImage(let baseURL):
            return AnyImageDisplayable(erasing: RelativePathImageDisplayable(baseURL: baseURL))
        case .assetImage(let name, let bundle):
            return AnyImageDisplayable(erasing: AssetImageDisplayable(name: name, bundle: bundle))
        }
    }
}

/// Load Network Images.
struct NetworkImageDisplayable: ImageDisplayable {
    func makeImage(url: URL, alt: String?) -> some View {
        NetworkImage(url: url, alt: alt)
    }
}

/// Load Images from relative path urls.
struct RelativePathImageDisplayable: ImageDisplayable {
    var baseURL: URL
    
    func makeImage(url: URL, alt: String?) -> some View {
        let completeURL = baseURL.appendingPathComponent(url.absoluteString)
        NetworkImage(url: completeURL, alt: alt)
    }
}

/// Load images from your Assets Catalog.
struct AssetImageDisplayable: ImageDisplayable {
    var name: (URL) -> String
    var bundle: Bundle?
    
    func makeImage(url: URL, alt: String?) -> some View {
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
