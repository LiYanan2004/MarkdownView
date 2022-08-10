import SwiftUI

struct LocalImage: View {
    var url: URL
    @State private var image: Image?
    @State private var localizedError: String?
    @Environment(\.displayScale) private var scale
    
    var body: some View {
        if let image {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else if let localizedError {
            VStack {
                Text(localizedError)
                    .padding(.vertical)
                    
                Text("Tap to reload.")
            }
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .containerShape(Rectangle())
            .onTapGesture(perform: reloadImage)
            .onChange(of: url) { _ in
                reloadImage()
            }
        } else {
            GeometryReader { proxy in
                Rectangle()
                    .foregroundStyle(.quaternary)
                    .aspectRatio(4 / 3, contentMode: .fit)
                    .opacity(0.5)
                    .task(priority: .background) {
                        await loadContent(size: proxy.size)
                    }
            }
        }
    }
    
    private func reloadImage() {
        image = nil
        localizedError = nil
    }
    
    private func loadContent(size: CGSize) async {
        do {
            let data = try await loadResource()
            #if os(macOS)
            if let image = NSImage(data: data) {
                self.image = Image(nsImage: image)
            }
            #elseif os(iOS) || os(tvOS)
            if let image = UIImage(data: data) {
                try await prepareThumbnailAndDisplay(for: image, size: size)
            }
            #endif
        } catch {
            localizedError = error.localizedDescription
            print(error.localizedDescription)
        }
    }
}

// MARK: - Helper
extension LocalImage {
    private func loadResource() async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
    
#if os(iOS) || os(tvOS)
    private func prepareThumbnailAndDisplay(for image: UIImage, size: CGSize) async throws {
        let thumbnailSize = thumbnailSize(for: image, byReferencing: size)
        if let thumbnail = await image.byPreparingThumbnail(ofSize: thumbnailSize) {
            self.image = Image(uiImage: thumbnail)
            return
        }
        throw ImageError.thumbnailError
    }
    
    private func thumbnailSize(for image: UIImage, byReferencing size: CGSize) -> CGSize {
        let aspectRatio = image.size.width / image.size.height
        let thumbnailHeight = size.width / aspectRatio
        
        return CGSize(width: size.width * scale, height: thumbnailHeight * scale)
    }
#endif
}

// MARK: - Errors
extension LocalImage {
    private enum ImageError: LocalizedError {
        case thumbnailError
        case resourceError
        
        var errorDescription: LocalizedStringKey? {
            switch self {
            case .thumbnailError: return "Failed to prepare a thumbnail"
            case .resourceError: return "Fetched Data is invalid"
            }
        }
    }
}
