//
//  MarkdownStyledLink.swift
//  MarkdownView
//
//  Created by Mahdi BND on 11/17/25.
//

import SwiftUI
import Markdown

struct MarkdownStyledLink: View {
    var link: Markdown.Link
    @Environment(\.linkStyle) private var linkStyle

    var body: some View {
        let configuration = LinkStyleConfiguration(
            destination: link.destination,
            title: link.title ?? link.plainText
        )

        linkStyle
            .makeBody(configuration: configuration)
            .erasedToAnyView()
    }
}
