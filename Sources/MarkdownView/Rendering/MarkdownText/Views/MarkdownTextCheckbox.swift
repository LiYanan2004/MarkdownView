//
//  MarkdownTextCheckbox.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/17.
//

import SwiftUI
import Markdown

struct MarkdownTextCheckbox: View {
    var checkbox: Checkbox
    var font: Font

    var body: some View {
        switch checkbox {
        case .checked:
            Image(systemName: "checkmark.circle.fill")
                .font(font)
                .foregroundStyle(.tint)
        case .unchecked:
            Image(systemName: "circle")
                .font(font)
                .foregroundStyle(.secondary)
        }
    }
}
