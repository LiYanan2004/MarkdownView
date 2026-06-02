//
//  MarkdownRendererConfiguration.Math.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/16.
//

import Foundation

extension MarkdownRendererConfiguration {
    struct Math: Sendable, Hashable {
        var shouldRender: Bool {
            get { displayMathStorage != nil }
            set(enabled) {
                if enabled {
                    displayMathStorage = [:]
                    inlineMathStorage = [:]
                } else {
                    displayMathStorage = nil
                    inlineMathStorage = nil
                }
            }
        }
        var displayMathStorage: [UUID : String]? = nil
        var inlineMathStorage: [UUID : String]? = nil
    }
}
