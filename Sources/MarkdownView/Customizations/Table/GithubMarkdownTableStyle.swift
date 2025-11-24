//
//  GithubMarkdownTableStyle.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/17.
//

import SwiftUI

/// A markdown table style that matches the style of table in GitHub.
public struct GithubMarkdownTableStyle: MarkdownTableStyle {
    public func makeBody(configuration: Configuration) -> some View {
        GithubMarkdownTable(
            configuration: configuration
        )
    }
}

extension MarkdownTableStyle where Self == GithubMarkdownTableStyle {
    /// A markdown table style that matches the style of table in GitHub.
    @preconcurrency
    @MainActor
    static public var github: GithubMarkdownTableStyle { .init() }
}

fileprivate struct GithubMarkdownTable: View {
    var configuration: MarkdownTableStyleConfiguration
    
    init(configuration: MarkdownTableStyleConfiguration) {
        self.configuration = configuration
    }
    
    @Environment(\.colorScheme) private var colorScheme
    
    /* Spacing values derived from GitHub's CSS table styles */
    private var horizontalSpacing: CGFloat = 13
    private var verticalSpacing: CGFloat = 6
    private var backgroundColor: Color {
        if colorScheme == .dark {
            Color(red: 14 / 255, green: 17 / 255, blue: 22 / 255)
        } else {
            Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)
        }
    }
    private var borderColor: Color {
        if colorScheme == .dark {
            Color(red: 61 / 255, green: 68 / 255, blue: 67 / 255)
        } else {
            Color(red: 209 / 255, green: 217 / 255, blue: 224 / 255)
        }
    }
    private var alternativeRowColor: Color {
        if colorScheme == .dark {
            Color(red: 21 / 255, green: 27 / 255, blue: 35 / 255)
        } else {
            Color(red: 246 / 255, green: 248 / 255, blue: 250 / 255)
        }
    }
    
    var body: some View {
        Group {
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                    configuration.table.header
                        
                    ForEach(Array(configuration.table.rows.enumerated()), id: \.offset) { (index, row) in
                        let backgroundStyle = index % 2 == 0 ? AnyShapeStyle(backgroundColor) : AnyShapeStyle(alternativeRowColor)
                        row
                            .markdownTableRowBackgroundStyle(backgroundStyle)
                    }
                }
            } else {
                configuration.table.fallback
            }
        }
        .markdownTableRowBackgroundStyle(backgroundColor)
        .markdownTableCellOverlay {
            Rectangle()
                .stroke(borderColor)
                .opacity(0.5)
        }
        .markdownTableCellPadding(.vertical, verticalSpacing)
        .markdownTableCellPadding(.horizontal, horizontalSpacing)
        .overlay {
            Rectangle()
                .stroke(borderColor)
                .opacity(0.5)
        }
    }
}
