//
//  GridMarkdownTableStyle.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/17.
//

import SwiftUI

/// A markdown table style that adds border to each cell.
public struct GridMarkdownTableStyle: MarkdownTableStyle {
    public func makeBody(configuration: Configuration) -> some View {
        GridMarkdownTable(
            configuration: configuration
        )
    }
}

extension MarkdownTableStyle where Self == GridMarkdownTableStyle {
    /// A very basic grid markdown table style, with each cell bordered.
    @preconcurrency
    @MainActor
    static public var grid: GridMarkdownTableStyle { .init() }
}

fileprivate struct GridMarkdownTable: View {
    var configuration: MarkdownTableStyleConfiguration
    
    init(configuration: MarkdownTableStyleConfiguration) {
        self.configuration = configuration
    }
    
    var body: some View {
        configuration.table
            .markdownTableCellOverlay {
                Rectangle()
                    .stroke(.foreground)
            }
    }
}
