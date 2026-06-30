//
//  MarkdownStreamingRenderThrottle+Environment.swift
//  MarkdownView
//

import SwiftUI

struct MarkdownStreamingRenderThrottleKey: EnvironmentKey {
    static let defaultValue: Duration = .milliseconds(50)
}

extension EnvironmentValues {
    var markdownStreamingRenderThrottle: Duration {
        get { self[MarkdownStreamingRenderThrottleKey.self] }
        set { self[MarkdownStreamingRenderThrottleKey.self] = newValue }
    }
}
