//
//  GithubMarkdownTableStyle.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/17.
//

import SwiftUI

/// A markdown table style that matches the style of GitHub.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct GithubMarkdownTableStyle: MarkdownTableStyle {
    public func makeBody(configuration: Configuration) -> some View {
        GithubMarkdownTable(
            configuration: configuration
        )
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension MarkdownTableStyle where Self == GithubMarkdownTableStyle {
    /// Default markdown table style.
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    @preconcurrency
    @MainActor
    static public var github: GithubMarkdownTableStyle { .init() }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
fileprivate struct GithubMarkdownTable: View {
    var configuration: MarkdownTableStyleConfiguration
    
    /* Spacing values derived from GitHub's CSS table styles */
    var horizontalSpacing: CGFloat = 13
    var verticalSpacing: CGFloat = 6
    
    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            configuration.header
                .safeAreaPadding(.vertical, verticalSpacing)
                .safeAreaPadding(.horizontal, horizontalSpacing)
                .markdownTableRowBackgroundStyle(.background)
                .markdownTableCellOverlay {
                    Rectangle()
                        .stroke(.placeholder)
                        .opacity(0.5)
                }
            ForEach(Array(configuration.rows.enumerated()), id: \.offset) { (index, row) in
                let backgroundStyle = index % 2 == 0 ? AnyShapeStyle(.background) : AnyShapeStyle(.background.secondary)
                row
                    .safeAreaPadding(.vertical, verticalSpacing)
                    .safeAreaPadding(.horizontal, horizontalSpacing)
                    .markdownTableRowBackgroundStyle(backgroundStyle)
                    .markdownTableCellOverlay {
                        Rectangle()
                            .stroke(.placeholder)
                            .opacity(0.5)
                    }
            }
        }
        .overlay {
            Rectangle()
                .stroke(.placeholder)
                .opacity(0.5)
        }
    }
}
