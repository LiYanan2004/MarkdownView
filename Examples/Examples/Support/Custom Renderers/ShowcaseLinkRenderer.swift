//
//  ShowcaseLinkRenderer.swift
//  Examples
//

import MarkdownView
import SwiftUI

struct ShowcaseLinkRenderer: MarkdownLinkRenderer {
    func makeBody(configuration: MarkdownLinkRendererConfiguration) -> some View {
        Link(destination: configuration.url) {
            HStack(spacing: 6) {
                configuration.label
                Image(systemName: "arrow.up.right")
                    .imageScale(.small)
            }
            .font(.callout)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.12), in: Capsule())
        }
        .foregroundStyle(.blue)
    }
}
