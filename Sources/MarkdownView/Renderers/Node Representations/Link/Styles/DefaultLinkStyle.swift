//
//  DefaultLinkStyle.swift
//  MarkdownView
//
//  Created by Mahdi BND on 11/17/25.
//

import SwiftUI

public struct DefaultLinkStyle: LinkStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        DefaultMarkdownLink(linkConfiguration: configuration, action: action)
    }

    public func action(_ url: URL) { }
}

struct DefaultMarkdownLink: View {
    var linkConfiguration: LinkStyleConfiguration
    var action: (_ url: URL) -> Void = { _ in }

    @Environment(\.markdownRendererConfiguration) private var renderingConfiguration

    var body: some View {
        if let destination = linkConfiguration.destination, let url = URL(string: destination) {
            MarkdownNodeView {
                Link(destination: url) {
                    Text(linkConfiguration.title ?? "link")
                }
                .foregroundStyle(renderingConfiguration.linkTintColor)
            }
        } else {
            if let title = linkConfiguration.title {
                MarkdownNodeView {
                    Text(title)
                        .foregroundStyle(renderingConfiguration.linkTintColor)
                }
            } else {
                EmptyView()
            }
        }
    }
}
