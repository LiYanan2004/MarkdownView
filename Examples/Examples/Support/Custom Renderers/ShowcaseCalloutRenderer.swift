//
//  ShowcaseCalloutRenderer.swift
//  Examples
//

import MarkdownView
import SwiftUI

struct ShowcaseCalloutRenderer: MarkdownBlockDirectiveRenderer {
    func makeBody(configuration: MarkdownBlockDirectiveRendererConfiguration) -> some View {
        ShowcaseCallout(configuration: configuration)
    }
}

struct ShowcaseCallout: View {
    var configuration: MarkdownBlockDirectiveRendererConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .imageScale(.small)

                Text(calloutType.capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(tintColor)

            MarkdownView(configuration.wrappedString)
        }
        .padding(12)
        .background(tintColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(tintColor)
                .frame(width: 4)
        }
    }

    private var calloutType: String {
        configuration.arguments
            .first(where: { $0.name == "type" })?
            .value
            .lowercased() ?? "note"
    }

    private var tintColor: Color {
        switch calloutType {
        case "tip":
            .green
        case "warning":
            .orange
        default:
            .blue
        }
    }

    private var iconName: String {
        switch calloutType {
        case "tip":
            "lightbulb"
        case "warning":
            "exclamationmark.triangle"
        default:
            "info.circle"
        }
    }
}
