//
//  ShowcaseSymbolImageRenderer.swift
//  Examples
//

import MarkdownView
import SwiftUI

struct ShowcaseSymbolImageRenderer: MarkdownImageRenderer {
    func makeBody(configuration: MarkdownImageRendererConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemName(from: configuration.url))
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(.purple)

            if let alternativeText = configuration.alternativeText {
                Text(alternativeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(Color.purple.opacity(0.10), in: RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.purple.opacity(0.25))
        }
    }

    private func systemName(from url: URL) -> String {
        url.host ?? "photo"
    }
}
