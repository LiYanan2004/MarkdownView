//
//  ImageTextRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/12.
//

import SwiftUI

struct ImageTextRenderer: MarkdownNode2TextRenderer {
    func body(context: Context) -> Text {
        if case let .image(image) = context.node.content {
            image
        }
    }
}

enum ImageLoader {
    static func load(_ url: URL) async throws -> Image {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        #if os(macOS)
        let nsImage = NSImage(data: data)
        guard let nsImage else {
            throw LoadError.invalidData
        }
        
        return Image(platformImage: nsImage)
        #else
        let uiImage = UIImage(data: data)
        guard let uiImage else {
            throw LoadError.invalidData
        }
        
        Image(platformImage: uiImage)
        #endif
    }
    
    enum LoadError: Error {
        case invalidData
    }
}
