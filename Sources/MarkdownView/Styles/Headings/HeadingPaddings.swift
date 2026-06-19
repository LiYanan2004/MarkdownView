//
//  HeadingPaddings.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/22.
//

import SwiftUI

struct HeadingPaddings: Sendable {
    private var _padding: [Int : EdgeInsets] = [
        1 : EdgeInsets(top: 24, leading: 0, bottom: 0, trailing: 0),
        2 : EdgeInsets(top: 24, leading: 0, bottom: 0, trailing: 0),
        3 : EdgeInsets(top: 24, leading: 0, bottom: 0, trailing: 0),
        4 : EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0),
        5 : EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0),
        6 : EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0),
    ]
    
    subscript(level: Int) -> EdgeInsets {
        get {
            guard (1...6).contains(level) else { return .init() }
            return _padding[level]!
        }
        set(insets) {
            guard (1...6).contains(level) else { return }
            _padding[level]! = insets
        }
    }
    
    subscript(level: Int, edge: Edge) -> CGFloat {
        get {
            guard (1...6).contains(level) else { return .zero }
            return switch edge {
            case .top:
                _padding[level]!.top
            case .leading:
                _padding[level]!.leading
            case .bottom:
                _padding[level]!.bottom
            case .trailing:
                _padding[level]!.trailing
            }
        }
        set(padding) {
            guard (1...6).contains(level) else { return }
            switch edge {
            case .top:
                _padding[level]!.top = padding
            case .leading:
                _padding[level]!.leading = padding
            case .bottom:
                _padding[level]!.bottom = padding
            case .trailing:
                _padding[level]!.trailing = padding
            }
        }
    }
}

// MARK: - Environment Values

struct HeadingPaddingsEnvironmentKey: EnvironmentKey {
    static let defaultValue: HeadingPaddings = .init()
}

extension EnvironmentValues {
    var headingPaddings: HeadingPaddings {
        get { self[HeadingPaddingsEnvironmentKey.self] }
        set { self[HeadingPaddingsEnvironmentKey.self] = newValue }
    }
}
