//
//  SwiftMathTypesettingTests.swift
//  MarkdownView
//

#if ENABLE_MATH_RENDERING

import SwiftMath
import Testing

@testable import MarkdownView

@Suite("SwiftMath Typesetting")
struct SwiftMathTypesettingTests {
    @Test(
        "Measures a formula's baseline from its own height",
        .tags(.math, .rendering)
    )
    @MainActor
    func measuresAFormulasBaselineFromItsOwnHeight() throws {
        let letter = try #require(
            SwiftMathTypesetting.metrics(for: "x", fontSize: 15, labelMode: .text)
        )
        let fraction = try #require(
            SwiftMathTypesetting.metrics(for: #"\frac{K}{N}"#, fontSize: 15, labelMode: .text)
        )

        #expect(letter.ascent > 0)
        #expect(fraction.ascent > letter.ascent)
    }

    @Test(
        "Finds no metrics for a formula SwiftMath can't typeset",
        .tags(.math, .rendering, .regression)
    )
    @MainActor
    func findsNoMetricsForAFormulaSwiftMathCantTypeset() {
        #expect(
            SwiftMathTypesetting.metrics(
                for: #"h(\text{ip}) \unknowncommand 2^{32}"#,
                fontSize: 15,
                labelMode: .text
            ) == nil
        )
    }

    @Test(
        "Finds no metrics for words in a script the math font can't draw",
        .tags(.math, .rendering, .regression)
    )
    @MainActor
    func findsNoMetricsForWordsInAScriptTheMathFontCantDraw() {
        #expect(
            SwiftMathTypesetting.metrics(
                for: #"0 \text{-ից մինչև } 2^{32} - 1"#, fontSize: 15, labelMode: .display
            ) == nil
        )
        #expect(SwiftMathTypesetting.metrics(for: #"\text{до } 2^{32}"#, fontSize: 15, labelMode: .text) != nil)
    }
}

#endif
