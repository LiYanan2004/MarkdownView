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
                } else {
                    displayMathStorage = nil
                }
            }
        }
        var displayMathStorage: [UUID : String]? = nil
        
        mutating func appendDisplayMath(_ displayMath: some StringProtocol) -> UUID {
            if displayMathStorage == nil {
                displayMathStorage = [:]
            }
            
            let id = UUID()
            displayMathStorage![id] = String(displayMath)
            return id
        }
    }
}
