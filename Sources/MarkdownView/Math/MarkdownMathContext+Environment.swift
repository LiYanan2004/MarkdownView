//
//  MarkdownMathContext+Environment.swift
//  MarkdownView
//

import SwiftUI

struct MarkdownMathContextKey: EnvironmentKey {
    static let defaultValue: MarkdownMathContext? = nil
}

extension EnvironmentValues {
    var markdownMathContext: MarkdownMathContext? {
        get { self[MarkdownMathContextKey.self] }
        set { self[MarkdownMathContextKey.self] = newValue }
    }
}
