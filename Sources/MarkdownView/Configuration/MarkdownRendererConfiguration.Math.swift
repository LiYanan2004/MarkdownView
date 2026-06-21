//
//  MarkdownRendererConfiguration.Math.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/16.
//

import Foundation

extension MarkdownRendererConfiguration {
    struct Math: Sendable, Hashable {
        var context: MarkdownMathContext?

        var shouldRender: Bool {
            get { context != nil }
            set(enabled) {
                context = enabled ? MarkdownMathContext() : nil
            }
        }

        var displayMathStorage: [UUID: String]? {
            get { context?.displayMathStorage }
            set { updateContext { $0.displayMathStorage = newValue ?? [:] } }
        }

        var inlineMathStorage: [UUID: String]? {
            get { context?.inlineMathStorage }
            set { updateContext { $0.inlineMathStorage = newValue ?? [:] } }
        }

        private mutating func updateContext(_ update: (inout MarkdownMathContext) -> Void) {
            var context = context ?? MarkdownMathContext()
            update(&context)
            self.context = context
        }
    }
}
