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

    var body: some View {
        if let destination = linkConfiguration.destination, let url = URL(string: destination) {
            Link(destination: url) {
                Text(linkConfiguration.title ?? "link")
            }
            .foregroundStyle(.blue)
            .environment(\.openURL, OpenURLAction { url in
                action(url)
                return .handled
            })
        } else {
            if let title = linkConfiguration.title {
                Text(title)
                    .foregroundStyle(.blue)
            } else {
                EmptyView()
            }
        }
    }
}

#Preview {
    SwiftUIView()
}
