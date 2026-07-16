//
//  MarkdownQuoteAlertStyle.swift
//  MarkdownView
//
//  Created by Phineas Guo on 2026/7/15.
//

import SwiftUI

extension MarkdownQuoteAlertType {
    var color: Color {
        switch self {
        case .note: Color(red: 47 / 255, green: 129 / 255, blue: 247 / 255)
        case .tip: Color(red: 87 / 255, green: 171 / 255, blue: 90 / 255)
        case .important: Color(red: 163 / 255, green: 113 / 255, blue: 247 / 255)
        case .warning: Color(red: 210 / 255, green: 153 / 255, blue: 34 / 255)
        case .caution: Color(red: 248 / 255, green: 81 / 255, blue: 73 / 255)
        }
    }
}

struct MarkdownQuoteAlert: View {
    var alertType: MarkdownQuoteAlertType
    var title: String
    var content: AnyView

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: alertType.systemImage)
                    .imageScale(.small)
                    .foregroundStyle(alertType.color)
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(alertType.color)
            }
            content
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            alertType.color.opacity(0.12),
            in: RoundedRectangle(cornerRadius: 10)
        )
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(alertType.color)
                .frame(width: 4)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MarkdownQuoteAlert(
        alertType: .warning,
        title: "Warning",
        content: AnyView(Text("Text"))
    )
}
