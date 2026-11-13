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

    /// Detects a quote alert type from a blockquote's first paragraph.
    ///
    /// Matches case-insensitively against:
    /// - `[!NOTE]`
    /// - `[!TIP]`
    /// - `[!IMPORTANT]`
    /// - `[!WARNING]`
    /// - `[!CAUTION]`
    ///
    /// The marker must be plain text and occupy the first line by itself. This
    /// deliberately excludes marker-like text wrapped in inline Markdown, such
    /// as code or strong emphasis.
    static func detect(
        from paragraph: Paragraph
    ) -> (type: MarkdownQuoteAlertType, title: String)? {
        let inlineChildren = Array(paragraph.children)
        guard let markerText = inlineChildren.first as? Markdown.Text else {
            return nil
        }

        if inlineChildren.count > 1 {
            guard inlineChildren[1] is SoftBreak
                    || inlineChildren[1] is LineBreak else {
                return nil
            }
        }

        return detect(fromMarker: markerText.string)
    }

    /// Detects an alert from a standalone marker string.
    static func detect(
        from text: String
    ) -> (type: MarkdownQuoteAlertType, title: String)? {
        let firstLine = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(
                maxSplits: 1,
                omittingEmptySubsequences: false,
                whereSeparator: { $0.isNewline }
            )
            .first ?? ""
        return detect(fromMarker: String(firstLine))
    }

    private static func detect(
        fromMarker marker: String
    ) -> (type: MarkdownQuoteAlertType, title: String)? {
        let trimmed = marker.trimmingCharacters(in: .whitespaces)

        // `NOTE` or `Note` can be also matched
        let uppercased = trimmed.uppercased()

        for type in Self.allCases {
            if uppercased == "[!\(type.rawValue)]" {
                return (type, type.defaultTitle)
            }
        }
        return nil
    }
}
