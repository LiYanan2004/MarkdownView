//
//  GithubBlockQuoteStyle.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/17.
//

import SwiftUI

/// Github block quote style that applies to a MarkdownView.
public struct GithubBlockQuoteStyle: BlockQuoteStyle {
    public func makeBody(configuration: Configuration) -> some View {
        GithubBlockQuoteView(configuration: configuration)
    }
}

extension BlockQuoteStyle where Self == GithubBlockQuoteStyle {
    /// A block quote style that matches the appearance of block quotes in Github..
    static public var github: GithubBlockQuoteStyle { .init() }
}

fileprivate struct GithubBlockQuoteView: View {
    var configuration: BlockQuoteStyleConfiguration
    #if os(macOS)
    @ScaledMetric(relativeTo: .body) private var fontSize: CGFloat = 13
    #elseif os(tvOS)
    @ScaledMetric(relativeTo: .body) private var fontSize: CGFloat = 36
    #else
    @ScaledMetric(relativeTo: .body) private var fontSize: CGFloat = 17
    #endif
    
    @Environment(\.colorScheme) private var colorScheme
    private var borderColor: Color {
        if colorScheme == .dark {
            Color(red: 62 / 255, green: 68 / 255, blue: 76 / 255)
        } else {
            Color(red: 210 / 255, green: 217 / 255, blue: 223 / 255)
        }
    }
    
    var body: some View {
        configuration.content
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyleGroup(_SecondaryForegroundStyleGroup())
            .foregroundStyle(.secondary)
            ._zeroPaddingForAllHeadings()
            .padding(.horizontal, fontSize)
            .safeAreaInset(edge: .leading, spacing: 0) {
                Rectangle()
                    .fill(borderColor)
                    .frame(width: 0.25 * fontSize)
            }
    }
}

// MARK: - Auxiliary

fileprivate struct _SecondaryForegroundStyleGroup: MarkdownForegroundStyleGroup {
    var h1: some ShapeStyle { .secondary }
    var h2: some ShapeStyle { .secondary }
    var h3: some ShapeStyle { .secondary }
    var h4: some ShapeStyle { .secondary }
    var h5: some ShapeStyle { .secondary }
    var h6: some ShapeStyle { .secondary }
}
