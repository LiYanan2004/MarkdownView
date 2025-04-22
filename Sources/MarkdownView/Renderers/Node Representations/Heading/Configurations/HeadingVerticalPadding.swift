//
//  HeadingVerticalPadding.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/22.
//

import SwiftUI

struct HeadingVerticalPadding: Sendable {
    private var _padding: [Int : CGFloat] = [
        1 : 24,
        2 : 24,
        3 : 24,
        4 : 10,
        5 : 10,
        6 : 10,
    ]
    
    subscript(level: Int) -> CGFloat {
        get {
            guard (1...6).contains(level) else { return .zero }
            return _padding[level]!
        }
        set(padding) {
            guard (1...6).contains(level) else { return }
            _padding[level]! = padding
        }
    }
}

// MARK: - Environment Values

@MainActor
struct HeadingVerticalPaddingEnvironmentKey: @preconcurrency EnvironmentKey {
    static var defaultValue: HeadingVerticalPadding = .init()
}

extension EnvironmentValues {
    var headingVerticalPadding: HeadingVerticalPadding {
        get { self[HeadingVerticalPaddingEnvironmentKey.self] }
        set { self[HeadingVerticalPaddingEnvironmentKey.self] = newValue }
    }
}
