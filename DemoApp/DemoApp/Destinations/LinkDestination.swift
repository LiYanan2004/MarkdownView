//
//  LinkDestination.swift
//  MarkdownView
//
//  Created by Mahdi BND on 11/17/25.
//

import SwiftUI
import MarkdownView

struct SwiftUIView: View {
    var body: some View {
        MarkdownView("""
        # MarkdownView
        
        Welcome to MarkdownView Demo App.
        
        MarkdownView is a dedicated package that provides a solution for Markdown text rendering. 
        
        It renders content as native SwiftUI View and supports built-in accessibility features.
        
        ### MarkdownView supports
        - Formatted Text, including: **bold**, _italic_, ~strike through~, [Link](https://apple.com), `inline code`
        """)
        .linkStyle(CustomLinkStyle())
    }
}

struct CustomLinkStyle: LinkStyle {
    init() {}

    func makeBody(configuration: Configuration) -> some View {
        CustomLinkStyleInternal(linkConfiguration: configuration, action: action)
    }

    func action(_ url: URL) {
        print("\(url) tapped")
    }
}

struct CustomLinkStyleInternal: View {
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

#Preview {
    SwiftUIView()
}
