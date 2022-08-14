import SwiftUI

#if os(macOS)
public typealias PlatformImage = NSImage
#else
public typealias PlatformImage = UIImage
#endif

public struct ImageCache: Identifiable, Equatable {
    public var id: URL
    public var image: PlatformImage
}

public class ImageCacheController: ObservableObject {
    public var caches: [ImageCache] = []
    
    public func addImageCache(url: URL, image: PlatformImage) {
        guard !caches.contains(where: { $0.id == url }) else { return }
        
        caches.append(ImageCache(id: url, image: image))
    }
    
    deinit {
        caches = []
    }
}
