//
//  NetworkMarkdownImageRenderer.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import SwiftUI

/// A markdown image renderer that loads a remote image.
struct NetworkMarkdownImageRenderer: MarkdownImageRenderer {
    func makeBody(configuration: Configuration) -> some View {
        NetworkImage(url: configuration.url, alt: configuration.alternativeText)
    }
}

extension MarkdownImageRenderer where Self == NetworkMarkdownImageRenderer {
    static var networkImage: NetworkMarkdownImageRenderer { .init() }
}
