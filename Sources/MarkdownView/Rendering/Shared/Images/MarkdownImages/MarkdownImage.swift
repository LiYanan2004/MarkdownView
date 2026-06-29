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

    init(image: Markdown.Image) {
        self.image = image
    }
    private var url: URL? {
        if let source = image.source {
            return URL(string: source)
        }
        return nil
    }
    private var alternativeText: String? {
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
    @Environment(\.markdownRendererConfiguration.preferredBaseURL) private var baseURL
    @Environment(\.markdownElementRenderers) private var elementRenderers
    
    var body: some View {
        if let url {
            let configuration = MarkdownImageRendererConfiguration(
                url: url,
                alternativeText: alternativeText
            )
            if let renderer = imageRenderer(for: url) {
                renderer
                    .makeBody(configuration: configuration)
                    .erasedToAnyView()
            } else if isNetworkImageURL(url) {
                NetworkMarkdownImageRenderer()
                    .makeBody(configuration: configuration)
                    .erasedToAnyView()
            } else if let baseURL {
                RelativePathMarkdownImageRenderer(baseURL: baseURL)
                    .makeBody(configuration: configuration)
                    .erasedToAnyView()
            } else {
                fallbackView
            }
        } else {
            fallbackView
        }
    }

    private var fallbackView: some View {
        Text(image.plainText)
    }

    private func imageRenderer(for url: URL) -> (any MarkdownImageRenderer)? {
        guard let scheme = url.scheme else {
            return nil
        }
        return elementRenderers
            .compactMap(\.image)
            .first(where: { $0.scheme == scheme })?
            .renderer
    }

    private func isNetworkImageURL(_ url: URL) -> Bool {
        url.scheme == "http" || url.scheme == "https"
    }
}
