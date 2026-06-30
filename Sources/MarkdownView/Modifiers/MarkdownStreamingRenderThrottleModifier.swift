//
//  MarkdownStreamingRenderThrottleModifier.swift
//  MarkdownView
//

import SwiftUI

extension View {
    /// Sets the minimum delay between streamed markdown render updates.
    ///
    /// Use this on ``StreamingMarkdownReader`` or an ancestor view to control how aggressively frequent source updates trigger visible re-renders. Smaller values allow render updates to occur more frequently, increasing rendering workload and potentially reducing performance while streaming continuous content.
    ///
    /// The default value is `50` milliseconds.
    ///
    /// - Parameter interval: The throttle interval applied to streaming render updates.
    nonisolated public func markdownStreamingRenderThrottle(_ interval: Duration) -> some View {
        environment(\.markdownStreamingRenderThrottle, interval)
    }
}
