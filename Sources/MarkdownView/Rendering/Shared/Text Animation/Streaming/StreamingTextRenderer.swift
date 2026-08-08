//
//  StreamingTextRenderer.swift
//  MarkdownView
//
//  Created by Phineas Guo on 2026/7/15.
//

import SwiftUI

/// A text renderer that progressively reveals text characters using a ``StreamingTextAnimation``.
///
/// Characters already revealed are drawn normally. Characters being revealed pass through
/// the animation, and characters not yet revealed are invisible.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct StreamingTextRenderer: TextRenderer {
    var progress: Double
    let revealedCount: Int
    let totalCharacterCount: Int
    let animation: any StreamingTextAnimation

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        let slices = layout.runSlices
        let totalCount = max(totalCharacterCount, 1)
        let transitionLength = max(totalCount - revealedCount, 1)

        // Wavefront position: how many characters into the transition zone
        // have been revealed. When progress=1, revealLength = transitionLength,
        // all characters are behind the wavefront.
        let revealLength = Double(transitionLength) * progress

        var currentCharacterOffset = 0

        for slice in slices {
            let sliceCount = slice.characterIndices.count
            let sliceRange = currentCharacterOffset..<(currentCharacterOffset + sliceCount)
            defer { currentCharacterOffset += sliceCount }

            // Zone 1: characters before revealedCount — fully revealed, draw normally.
            if sliceRange.upperBound <= revealedCount {
                context.draw(slice, options: .disablesSubpixelQuantization)
                continue
            }

            // Zone 3: characters entirely past the wavefront — invisible.
            if Double(sliceRange.lowerBound - revealedCount) >= revealLength {
                continue
            }

            // Zone 2: slice overlaps the wavefront — apply animation.
            let firstInZone = max(sliceRange.lowerBound, revealedCount)
            let positionInZone = Double(firstInZone - revealedCount)

            // characterProgress = 1 when the wavefront has passed this slice,
            // fractional when the wavefront is passing through it.
            let characterProgress = min(max(revealLength - positionInZone, 0), 1)

            var sliceContext = context
            animation.apply(to: &sliceContext, characterProgress: characterProgress)
            sliceContext.draw(slice, options: .disablesSubpixelQuantization)
        }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
private extension Text.Layout {
    var runSlices: [Text.Layout.RunSlice] {
        var slices: [Text.Layout.RunSlice] = []
        for line in self {
            for run in line {
                for slice in run {
                    slices.append(slice)
                }
            }
        }
        return slices
    }
}
