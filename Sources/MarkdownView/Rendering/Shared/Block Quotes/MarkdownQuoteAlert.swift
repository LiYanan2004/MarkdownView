//
//  MarkdownQuoteAlert.swift
//  MarkdownView
//
//  Created by Phineas Guo on 2026/7/15.
//

import SwiftUI
import Markdown

/// The type of a GitHub-style quote alert blockquote.
enum MarkdownQuoteAlertType: String, CaseIterable {
    case note = "NOTE"
    case tip = "TIP"
    case important = "IMPORTANT"
    case warning = "WARNING"
    case caution = "CAUTION"

    var systemImage: String {
        switch self {
        case .note: "info.circle"
        case .tip: "lightbulb"
        case .important: "exclamationmark.circle"
        case .warning: "exclamationmark.triangle"
        case .caution: "xmark.octagon"
        }
    }

    var defaultTitle: String {
        switch self {
        case .note: "Note"
        case .tip: "Tip"
        case .important: "Important"
        case .warning: "Warning"
        case .caution: "Caution"
        }
    }

    /// Detects a quote alert type from the text of a blockquote's first paragraph.
    ///
    /// Matches case-insensitively against:
    /// - `[!NOTE]`
    /// - `[!TIP]`
    /// - `[!IMPORTANT]`
    /// - `[!WARNING]`
    /// - `[!CAUTION]`
    ///
    /// Text after the marker is used as a custom title.
    static func detect(from text: String) -> (type: MarkdownQuoteAlertType, title: String)? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // `NOTE` or `Note` can be also matched
        let uppercased = trimmed.uppercased()

        for type in Self.allCases {
            let prefix = "[!\(type.rawValue)]"
            if uppercased.hasPrefix(prefix) {
                let remaining = trimmed.dropFirst(prefix.count)
                    .trimmingCharacters(in: .whitespaces)
                let title = remaining.isEmpty ? type.defaultTitle : String(remaining)
                return (type, title)
            }
        }
        return nil
    }
}
