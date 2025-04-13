//
//  MarkdownImage.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/22.
//

import Markdown
import SwiftUI

struct MarkdownImage: View {
    var image: Markdown.Image
    private var url: URL? {
        if let source = image.source {
            return URL(string: source)
        }
        return nil
    }
    private var alt: String? {
        if !(image.parent is Markdown.Link) {
            if let title = image.title, !title.isEmpty {
                return title
            } else {
                return image.plainText.isEmpty ? nil : image.plainText
            }
        } else {
            // If the image is inside a link, then ignore the alternative text
            return nil
        }
    }
    private var provider: (any ImageDisplayable)? {
        guard let imageScheme = url?.scheme else { return nil }
        for (scheme, imageProvider) in configuration.imageRenderer.imageProviders {
            if imageScheme.localizedLowercase == scheme.localizedLowercase {
                return imageProvider
            }
        }
        return nil
    }
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    
    var body: some View {
        if let url {
            configuration.imageRenderer.loadImage(provider, url: url, alt: alt)
        } else {
            MarkdownNodeView {
                Text(image.plainText)
            }
        }
    }
}
