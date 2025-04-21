//
//  MarkdownTableStyleConfiguration.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/21.
//

import SwiftUI

/// The properties of a markdown table.
@preconcurrency
@MainActor
public struct MarkdownTableStyleConfiguration {
    /// The table view, `Grid` on supported platforms and `AdaptiveGrid` otherwise.
    public var table: MarkdownTableStyleConfiguration.Table
}

@available(*, unavailable)
extension MarkdownTableStyleConfiguration: Sendable {
    
}
