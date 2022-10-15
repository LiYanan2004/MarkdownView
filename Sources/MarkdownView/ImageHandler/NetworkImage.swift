import SwiftUI
import SVGKit

struct NetworkImage: View {
    var url: URL
    var alt: String?
    @State private var image: Image?
    @State private var imageSize = CGSize.zero
    @State private var localizedError: String?
    @Environment(\.displayScale) private var scale
    @Environment(\.containerSize) private var containerSize
    @EnvironmentObject private var cacheController: ImageCacheController
    
    var body: some View {
        VStack {
            if let image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: imageSize.width)
            } else if let localizedError {
                Text(localizedError + "\n" + "Tap to reload.")
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .containerShape(Rectangle())
                    .onTapGesture(perform: reloadImage)
            } else {
                // Placeholder height = 5
                let height = imageSize != .zero ? containerSize.width / imageSize.width * imageSize.height : 5
                Color.black.opacity(0.001)
                    .frame(maxWidth: imageSize == .zero ? .infinity : imageSize.width)
                    .frame(height: height)
            }

            if let alt {
                Text(alt)
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }
        }
        .overlay {
            GeometryReader { proxy in
                Color.black.opacity(0.001)
                    .task(id: url) {
                        reloadImage()
                        await loadContent(size: proxy.size)
                        showImage()
                    }
            }
        }
    }
    
    private func reloadImage() {
        image = nil
        localizedError = nil
        imageSize = CGSize.zero
    }
    
    private func loadContent(size: CGSize) async {
        // Load image from Cache directly.
        if isCached {
            showImage()
            return
        }
        do {
            let data = try await loadResource()
            #if os(macOS)
            if let image = NSImage(data: data) {
                cacheController.cacheImage(image, url: url)
            } else {
                try await loadAsSVG(data: data)
            }
            #elseif os(iOS) || os(tvOS)
            if let image = UIImage(data: data) {
                try await prepareThumbnailAndDisplay(for: image, size: size)
            } else {
                try await loadAsSVG(data: data)
            }
            #endif
        } catch {
            localizedError = error.localizedDescription
            print(error.localizedDescription)
        }
    }
    
    func showImage() {
        guard let image = cacheController.image(from: url) else { return }
        self.imageSize = image.size
#if os(iOS) || os(tvOS)
        self.image = Image(uiImage: image)
#else
        self.image = Image(nsImage: image)
#endif
    }
    
    var isCached: Bool {
        cacheController.image(from: url) != nil
    }
}

// MARK: - Helper
extension NetworkImage {
    private func loadResource() async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        return data
    }
    
#if os(iOS) || os(tvOS)
    private func prepareThumbnailAndDisplay(for image: UIImage, size: CGSize) async throws {
        if size.width >= image.size.width {
            cacheController.cacheImage(image, url: url)
            return
        }
        let thumbnailSize = thumbnailSize(for: image, byReferencing: size)
        if let thumbnail = await image.byPreparingThumbnail(ofSize: thumbnailSize) {
            showImage(thumbnail)
        } else {
            throw ImageError.thumbnailError
        }
    }
    
    private func thumbnailSize(for image: UIImage, byReferencing size: CGSize) -> CGSize {
        let aspectRatio = image.size.width / image.size.height
        let thumbnailHeight = size.width / aspectRatio
        
        return CGSize(width: size.width * scale, height: thumbnailHeight * scale)
    }
#endif
    
    func loadAsSVG(data: Data) async throws {
        guard String(data: data, encoding: .utf8)?.contains("<svg") ?? false else {
            throw ImageError.formatError
        }
        let source = SVGKSource(inputSteam: InputStream(data: data))
#if os(iOS) || os(tvOS)
        if let image = SVGKImage(source: source).uiImage {
            cacheController.cacheImage(image, url: url)
        } else { throw ImageError.formatError }
#else
        if let image = SVGKImage(source: source).nsImage {
            cacheController.cacheImage(image, url: url)
        } else { throw ImageError.formatError }
#endif
    }
}

// MARK: - Errors
extension NetworkImage {
    private enum ImageError: String, LocalizedError, CustomStringConvertible {
        case thumbnailError = "Failed to prepare a thumbnail"
        case resourceError = "Fetched Data is invalid"
        case formatError = "Unsupported Image format"
        
        var errorDescription: LocalizedStringKey? {
            switch self {
            case .thumbnailError: return "Failed to prepare a thumbnail"
            case .resourceError: return "Fetched Data is invalid"
            case .formatError: return "Unsupported Image format"
            }
        }
        
        var description: String {
            switch self {
            case .thumbnailError: return "Failed to prepare a thumbnail"
            case .resourceError: return "Fetched Data is invalid"
            case .formatError: return "Unsupported Image format"
            }
        }
    }
}
