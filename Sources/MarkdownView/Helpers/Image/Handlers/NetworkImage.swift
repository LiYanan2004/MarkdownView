import SwiftUI
#if !os(watchOS)
import SVGKit
#endif

struct NetworkImage: View {
    var url: URL
    var alt: String?
    @State private var image: Image?
    @State private var imageSize = CGSize.zero
    @State private var localizedError: String?
    @Environment(\.displayScale) private var scale
    @Environment(\.containerSize) private var containerSize
    
    var body: some View {
        VStack {
            if let image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: imageSize.width)
            } else if let localizedError {
                Text(localizedError + "\n" + "Tap to reload.")
                    .textSelection(.disabled)
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .containerShape(Rectangle())
                    .onTapGesture(perform: reloadImage)
            } else {
                ProgressView()
                    .controlSize(.small)
                    .frame(maxWidth: imageSize == .zero ? .infinity : imageSize.width)
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
                    .allowsHitTesting(false)
                    .task(id: url) {
                        do {
                            try await loadContent(size: proxy.size)
                        } catch {
                            localizedError = error.localizedDescription
                            print(error.localizedDescription)
                        }
                    }
            }
        }
    }
    
    private func reloadImage() {
        image = nil
        localizedError = nil
        imageSize = CGSize.zero
    }
    
    private func loadContent(size: CGSize) async throws {
        let data = try await loadResource()
        
        #if os(macOS)
        if let image = NSImage(data: data) {
            self.image = Image(nsImage: image)
            self.imageSize = image.size
            return
        }
        #elseif os(iOS) || os(tvOS)
        if let image = UIImage(data: data) {
            try await prepareThumbnailAndDisplay(for: image, size: size)
            self.imageSize = image.size
            return
        }
        #endif
        #if !os(watchOS)
        try await loadAsSVG(data: data)
        #endif
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
        let thumbnailSize = thumbnailSize(for: image, byReferencing: size)
        if let thumbnail = await image.byPreparingThumbnail(ofSize: thumbnailSize) {
            self.image = Image(uiImage: thumbnail)
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
        guard String(data: data, encoding: .utf8)?.starts(with: "<svg") ?? false else {
            throw ImageError.formatError
        }
        let source = SVGKSource(inputSteam: InputStream(data: data))
        #if os(iOS) || os(tvOS)
        if let image = SVGKImage(source: source).uiImage {
            self.image = Image(uiImage: image)
        } else { throw ImageError.formatError }
        #else
        if let image = SVGKImage(source: source).nsImage {
            self.image = Image(nsImage: image)
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

#if os(macOS)
typealias PlatformImage = NSImage
#else
typealias PlatformImage = UIImage
#endif

extension Image {
    init(platformImage: PlatformImage) {
        #if os(macOS)
        self.init(nsImage: platformImage)
        #else
        self.init(uiImage: platformImage)
        #endif
    }
}
