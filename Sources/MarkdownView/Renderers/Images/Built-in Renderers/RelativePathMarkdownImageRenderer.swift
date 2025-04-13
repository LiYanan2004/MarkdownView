//
//  RelativePathMarkdownImageRenderer.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import SwiftUI

/// A markdown image renderer that loads a remote image from a relative url.
struct RelativePathMarkdownImageRenderer: MarkdownImageRenderer {
    var baseURL: URL
    
    func makeBody(configuration: Configuration) -> some View {
        let (url, alt) = (configuration.url, configuration.alternativeText)
        let resolvedPath = URL(
            string: url.absoluteString,
            relativeTo: baseURL
        )?.standardized.resolvingSymlinksInPath()
        
        return NetworkImage(url: resolvedPath ?? url, alt: alt)
    }
}

extension MarkdownImageRenderer where Self == RelativePathMarkdownImageRenderer {
    static func relativePathImage(baseURL: URL) -> RelativePathMarkdownImageRenderer {
        RelativePathMarkdownImageRenderer(baseURL: baseURL)
    }
}
