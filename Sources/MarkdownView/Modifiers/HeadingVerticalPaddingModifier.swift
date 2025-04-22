//
//  HeadingVerticalPaddingModifier.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/22.
//

import SwiftUI

extension View {
    /// Sets vertical paddings for specific heading.
    ///
    /// Default amount of paddings are:
    /// - h1: 24
    /// - h2: 24
    /// - h3: 24
    /// - h4: 10
    /// - h5: 10
    /// - h6: 10
    ///
    /// - parameter length: The length of the vertical padding on each side.
    /// - parameter headingLevel: The level of the heading to use the specified padding length.
    nonisolated public func padding(
        _ length: CGFloat,
        for headingLevel: HeadingLevel
    ) -> some View {
        transformEnvironment(\.headingVerticalPadding) { padding in
            padding[headingLevel.rawValue] = length
        }
    }
}
