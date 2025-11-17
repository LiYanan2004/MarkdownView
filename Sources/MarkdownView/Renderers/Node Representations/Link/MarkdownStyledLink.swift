//
//  MarkdownStyledLink.swift
//  MarkdownView
//
//  Created by Mahdi BND on 11/17/25.
//

import SwiftUI

struct MarkdownStyledLink: View {
    var configuration: LinkStyleConfiguration
    @Environment(\.linkStyle) private var linkStyle

    var body: some View {
        linkStyle
            .makeBody(configuration: configuration)
            .erasedToAnyView()
    }
}
