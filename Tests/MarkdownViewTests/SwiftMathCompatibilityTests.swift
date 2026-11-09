//
//  SwiftMathCompatibilityTests.swift
//  MarkdownView
//

#if ENABLE_MATH_RENDERING

import Testing

@testable import MarkdownView

@Suite("SwiftMath Compatibility")
@MainActor
struct SwiftMathCompatibilityTests {
    init() {
        SwiftMathCompatibility.registerSymbols()
    }

    @Test(
        "Says common commands SwiftMath lacks with ones it knows",
        .tags(.math),
        arguments: [
            (#"\dfrac{a}{b} + \tfrac{1}{2}"#, #"\frac{a}{b} + \frac{1}{2}"#),
            (#"2 + 2 > 3 \implies 4 > 3"#, #"2 + 2 > 3 \;\Longrightarrow\; 4 > 3"#),
            (#"a \equiv b \pmod{N}"#, #"a \equiv b \;(\mathrm{mod}\;N)"#),
            (#"\text{Hash(Key)} \pmod N"#, #"\text{Hash(Key)} \;(\mathrm{mod}\;N)"#),
            (#"x \pmod\alpha"#, #"x \;(\mathrm{mod}\;\alpha)"#),
            (#"h \bmod 2^{32}"#, #"h \;\mathrm{mod}\; 2^{32}"#),
            (#"\operatorname{argmax}_x f"#, #"\mathrm{argmax}_x f"#),
            (#"\lvert x \rvert"#, "| x |"),
            (#"\Big( x \Big)"#, "( x )"),
            (#"1, 2, \dots, n"#, #"1, 2, \ldots, n"#),
            ("αb ≤ 2", #"\alpha b \leq  2"#),
            (#"x → y \text{ για }"#, #"x \rightarrow  y \text{ για }"#),
            ("a ≠ b ∉ ℝ", #"a \neq  b \notin  \mathbb{R} "#),
            (#"x \pmod{2^{k}}"#, #"x \;(\mathrm{mod}\;2^{k})"#),
        ]
    )
    func saysCommonCommandsWithOnesSwiftMathKnows(source: String, typeset: String) {
        #expect(SwiftMathCompatibility.rewrite(source) == typeset)
    }

    @Test(
        "Leaves supported LaTeX, longer names and the letters after a line break alone",
        .tags(.math, .regression)
    )
    func leavesSupportedLaTeXLongerNamesAndLineBreaksAlone() {
        for latex in [#"\models"#, #"\frac{K}{N} \pm O(\sqrt{K})"#, #"\mathrm{mod}"#,
                      #"\dotsxyz"#, #"a \\ dArr"#, #"\{ x \}"#] {
            #expect(SwiftMathCompatibility.rewrite(latex) == latex)
        }
    }

    @Test(
        "Typesets every symbol of the table with a glyph of the math font",
        .tags(.math, .rendering)
    )
    @MainActor
    func typesetsEverySymbolOfTheTable() {
        let blank = KaTeXCompatibilityTable.symbols.filter { symbol in
            let metrics = SwiftMathTypesetting.metrics(for: "\\" + symbol.name, fontSize: 15, labelMode: .text)
            return (metrics?.width ?? 0) <= 0
        }
        #expect(blank.isEmpty, "Not typeset: \(blank.map(\.name))")
    }

    @Test(
        "Typesets every macro of the table",
        .tags(.math, .rendering)
    )
    @MainActor
    func typesetsEveryMacroOfTheTable() {
        let failing = KaTeXCompatibilityTable.macros.keys.sorted().filter { name in
            SwiftMathTypesetting.metrics(
                for: SwiftMathCompatibility.rewrite("\\" + name), fontSize: 15, labelMode: .text
            ) == nil
        }
        #expect(failing.isEmpty, "Not typeset: \(failing)")
    }

    @Test(
        "Typesets every Unicode character it reads as a command",
        .tags(.math, .rendering)
    )
    @MainActor
    func typesetsEveryUnicodeCharacterItReadsAsACommand() {
        let failing = SwiftMathCompatibility.unicode.keys.sorted().filter { character in
            SwiftMathTypesetting.metrics(
                for: SwiftMathCompatibility.rewrite(String(character)), fontSize: 15, labelMode: .text
            ) == nil
        }
        #expect(failing.isEmpty, "Not typeset: \(failing)")
        #expect(SwiftMathCompatibility.unicode["¶"] == nil)
    }

    @Test(
        "Typesets most of what KaTeX supports",
        .tags(.math, .rendering, .regression)
    )
    @MainActor
    func typesetsMostOfWhatKaTeXSupports() {
        let typesetBefore = katexExamples.filter { example in
            SwiftMathTypesetting.metrics(for: example.example, fontSize: 15, labelMode: .text) != nil
        }
        let typesetNow = katexExamples.filter { example in
            SwiftMathTypesetting.metrics(
                for: SwiftMathCompatibility.rewrite(example.example), fontSize: 15, labelMode: .text
            ) != nil
        }
        print("KaTeX examples typeset: \(typesetBefore.count) of \(katexExamples.count) by SwiftMath, "
              + "\(typesetNow.count) with the compatibility table")
        // Today's coverage: a change that loses commands fails here
        #expect(typesetNow.count >= 655)
        #expect(typesetNow.count > typesetBefore.count)
    }

    @Test(
        "Typesets what the rewrite produces",
        .tags(.math, .rendering)
    )
    @MainActor
    func typesetsWhatTheRewriteProduces() {
        for source in [#"2 + 2 > 3 \implies 4 > 3"#, #"a \equiv b \pmod{N}"#, #"h \bmod 2^{32}"#,
                       #"\text{Shard} = \text{Hash(Key)} \pmod N"#, "α + β ≤ γ", "x ∈ ℝ",
                       #"\dfrac{a}{b}"#, #"\operatorname{lcm}(a, b)"#] {
            #expect(
                SwiftMathTypesetting.metrics(
                    for: SwiftMathCompatibility.rewrite(source),
                    fontSize: 15,
                    labelMode: .text
                ) != nil,
                "\(source) still can't be typeset"
            )
        }
    }
}

#endif
