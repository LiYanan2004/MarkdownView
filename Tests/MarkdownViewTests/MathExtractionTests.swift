//
//  MathExtractionTests.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/9.
//

import Testing
@testable import MarkdownView

@Suite("Math Extraction")
struct MathExtractionTests {
    @Test
    func testExtractsDollarDelimitedInlineMath() async throws {
        let markdown = #"""
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. The sample mean is $\bar{x} = \frac{1}{n}\sum_{i=1}^{n}x_i$, and the report continues with ordinary prose.
        """#

        #expect(extractedMath(in: markdown) == [
            #"$\bar{x} = \frac{1}{n}\sum_{i=1}^{n}x_i$"#,
        ])
    }

    @Test
    func testExtractsParenthesesDelimitedInlineMath() async throws {
        let markdown = #"""
        Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. The confidence interval \( \hat{p} \pm z_{\alpha/2}\sqrt{\frac{\hat{p}(1-\hat{p})}{n}} \) appears inline.
        """#

        #expect(extractedMath(in: markdown) == [
            #"\( \hat{p} \pm z_{\alpha/2}\sqrt{\frac{\hat{p}(1-\hat{p})}{n}} \)"#,
        ])
    }

    @Test
    func testExtractsDollarDelimitedDisplayMath() async throws {
        let markdown = #"""
        Pellentesque habitant morbi tristique senectus et netus et malesuada fames.

        $$\int_{0}^{1} x^2\,dx = \frac{1}{3}$$

        Donec ullamcorper nulla non metus auctor fringilla.
        """#

        #expect(extractedMath(in: markdown) == [
            #"$$\int_{0}^{1} x^2\,dx = \frac{1}{3}$$"#,
        ])
    }

    @Test
    func testExtractsBracketDelimitedDisplayMath() async throws {
        let markdown = #"""
        Cras mattis consectetur purus sit amet fermentum.

        \[
        \nabla \cdot \mathbf{E} = \frac{\rho}{\varepsilon_0}
        \]

        Integer posuere erat a ante venenatis dapibus.
        """#

        #expect(extractedMath(in: markdown) == [
            #"""
            \[
            \nabla \cdot \mathbf{E} = \frac{\rho}{\varepsilon_0}
            \]
            """#,
        ])
    }

    @Test
    func testExtractsNamedEquation() async throws {
        let markdown = #"""
        Maecenas sed diam eget risus varius blandit sit amet non magna.

        \begin{equation}
        E = mc^2
        \end{equation}

        Etiam porta sem malesuada magna mollis euismod.
        """#

        #expect(extractedMath(in: markdown) == [
            #"""
            \begin{equation}
            E = mc^2
            \end{equation}
            """#,
        ])
    }

    @Test
    func testExtractsUnnumberedNamedEquation() async throws {
        let markdown = #"""
        Nullam id dolor id nibh ultricies vehicula ut id elit.

        \begin{equation*}
        a^2 + b^2 = c^2
        \end{equation*}

        Aenean lacinia bibendum nulla sed consectetur.
        """#

        #expect(extractedMath(in: markdown) == [
            #"""
            \begin{equation*}
            a^2 + b^2 = c^2
            \end{equation*}
            """#,
        ])
    }

    @Test(
        "Extracts standalone SwiftMath environments",
        arguments: [
            "matrix", "pmatrix", "bmatrix", "Bmatrix", "vmatrix", "Vmatrix",
            "eqalign", "split", "aligned", "displaylines", "gather", "eqnarray", "cases",
        ]
    )
    func extractsStandaloneSwiftMathEnvironment(environmentName: String) {
        let environment = "\\begin{\(environmentName)}x & y\\end{\(environmentName)}"

        #expect(extractedMath(in: "Display math: \(environment)") == [environment])
    }

    @Test
    func extractsOuterEnvironmentContainingNestedEnvironment() {
        let markdown = #"\begin{gather}x = \begin{pmatrix}1 & 2\end{pmatrix}\end{gather}"#

        #expect(extractedMath(in: markdown) == [markdown])
    }

    @Test
    func ignoresUnsupportedStandaloneEnvironment() {
        let markdown = #"\begin{document}ordinary text\end{document}"#

        #expect(extractedMath(in: markdown).isEmpty)
    }

    @Test
    func recognizesDelimiterFollowingAnEvenNumberOfBackslashes() {
        let markdown = #"Text ends with a command break \\$x$"#

        #expect(extractedMath(in: markdown) == [#"$x$"#])
    }

    @Test
    func ignoresDelimiterFollowingAnOddNumberOfBackslashes() {
        let markdown = #"The delimiter is escaped: \$x$"#

        #expect(extractedMath(in: markdown).isEmpty)
    }

    @Test
    func ignoresUnterminatedInlineDollarMathBeforeLaterCompletedExpression() {
        let markdown = #"Price moved from $73.00 and the valid equation is $x$."#

        #expect(extractedMath(in: markdown) == [#"$x$"#])
    }

    @Test
    func ignoresUnterminatedBracketDisplayMathDuringStreaming() {
        let markdown = #"""
        \[
        E = mc^2
        """#

        let result = processMarkdownParsingRanges(in: markdown)

        #expect(result.markdown == markdown)
        #expect(result.displayMathStorage.isEmpty)
        #expect(result.inlineMathStorage.isEmpty)
    }

    @Test
    func testMathPreprocessingProtectsInlineMathUnderscores() async throws {
        let result = processMarkdownParsingRanges(in: #"Lorem ipsum dolor sit amet, $(a_n)_{n \in \mathbb{N}}$ and $(b_n)_{n \in \mathbb{N}}$ are both geometric sequences."#)

        #expect(result.inlineMathStorage.count == 2)
        #expect(result.displayMathStorage.isEmpty)
        #expect(Set(result.inlineMathStorage.values) == Set([
            #"$(a_n)_{n \in \mathbb{N}}$"#,
            #"$(b_n)_{n \in \mathbb{N}}$"#,
        ]))
        #expect(!result.markdown.contains("_"))
    }

    @Test
    func testPreprocessReturnsProcessedMarkdown() async throws {
        let markdown = #"The sample mean is $\bar{x}$."#
        let processedMarkdown = MarkdownMathPreprocessor().preprocess(markdown)

        #expect(processedMarkdown.contains("markdownview-math(inline:"))
        #expect(!processedMarkdown.contains(#"$\bar{x}$"#))
    }

    @Test
    func testMathPreprocessingLeavesPlainTextUntouched() async throws {
        let markdown = "Plain prose without any supported math delimiters."
        let result = processMarkdownParsingRanges(in: markdown)

        #expect(result.markdown == markdown)
        #expect(result.displayMathStorage.isEmpty)
        #expect(result.inlineMathStorage.isEmpty)
    }

    @Test
    func testMathPreprocessingLeavesHardLineBreakTextUntouched() async throws {
        let markdown = #"""
        Hard line break\
        starts a new rendered line.
        """#
        let result = processMarkdownParsingRanges(in: markdown)

        #expect(result.markdown == markdown)
        #expect(result.displayMathStorage.isEmpty)
        #expect(result.inlineMathStorage.isEmpty)
    }

    @Test
    func testMathPreprocessingStoresDollarDisplayMathWithDelimiters() async throws {
        let markdown = #"""
        Display math:

        $$
        \int_0^1 x^2\,dx = \frac{1}{3}
        $$
        """#
        let result = processMarkdownParsingRanges(in: markdown)

        #expect(
            result.displayMathStorage.values.first == #"""
            $$
            \int_0^1 x^2\,dx = \frac{1}{3}
            $$
            """#
        )
        #expect(result.markdown.contains("markdownview-math(display:"))
    }

    @Test
    func testMathPreprocessingStoresBracketDisplayMathWithDelimiters() async throws {
        let markdown = #"""
        \[
        \nabla \cdot \mathbf{E} = \frac{\rho}{\varepsilon_0}
        \]
        """#
        let result = processMarkdownParsingRanges(in: markdown)

        #expect(
            result.displayMathStorage.values.first == #"""
            \[
            \nabla \cdot \mathbf{E} = \frac{\rho}{\varepsilon_0}
            \]
            """#
        )
    }

    @Test
    func testMathPreprocessingKeepsExistingDisplayMathIdentifierWhenAppendingTrailingContent() async throws {
        let previousMarkdown = #"""
        Alpha

        $$
        y
        $$
        """#
        let appendedMarkdown = previousMarkdown + #"""

        Beta
        """#

        let previousResult = processMarkdownParsingRanges(in: previousMarkdown)
        let appendedResult = processMarkdownParsingRanges(in: appendedMarkdown)

        #expect(
            Set(previousResult.displayMathStorage.keys)
                .isSubset(of: Set(appendedResult.displayMathStorage.keys))
        )
    }

    @Test
    func testMathPreprocessingUsesUnifiedParsableMarkers() async throws {
        let markdown = #"""
        Inline math: $x$

        $$
        y
        $$
        """#
        let result = processMarkdownParsingRanges(in: markdown)

        let inlineIdentifier = try #require(result.inlineMathStorage.keys.first)
        let displayIdentifier = try #require(result.displayMathStorage.keys.first)

        #expect(
            MarkdownMathPreprocessor.placeholderMatch(
                in: MarkdownMathPreprocessor.inlinePlaceholder(for: inlineIdentifier)
            ) == .init(kind: .inline, identifier: inlineIdentifier)
        )
        #expect(
            MarkdownMathPreprocessor.placeholderMatch(
                in: MarkdownMathPreprocessor.displayPlaceholder(for: displayIdentifier)
            ) == .init(kind: .display, identifier: displayIdentifier)
        )
    }

    @Test
    func testMathPreprocessingPreservesEscapedBracketPunctuation() async throws {
        let markdown = #"Escaped punctuation: \*literal asterisks\*, \[literal brackets\], and \`literal backticks\`."#
        let result = processMarkdownParsingRanges(in: markdown)

        #expect(result.markdown == markdown)
        #expect(result.displayMathStorage.isEmpty)
        #expect(result.inlineMathStorage.isEmpty)
    }

    @Test
    func testExtractsIndentedBracketDelimitedDisplayMath() async throws {
        let markdown = #"""
        Introductory text.

            \[
            E = mc^2
            \]
        """#

        #expect(extractedMath(in: markdown) == [
            #"""
            \[
                E = mc^2
                \]
            """#,
        ])
    }

    @Test
    func testMathPreprocessingPreservesInlineCodeMathLiteral() async throws {
        let markdown = #"Lorem ipsum keeps `$x_y$` as source text while rendering $a_b$ in the same sentence."#
        let result = processMarkdownParsingRanges(in: markdown)

        #expect(result.markdown.contains(#"`$x_y$`"#))
        #expect(Array(result.inlineMathStorage.values) == [#"$a_b$"#])
    }

    @Test
    func testMathPreprocessingPreservesFencedCodeBlockMathLiteral() async throws {
        let markdown = #"""
        ```latex
        $x^2 + y^2 = c^2$
        ```

        Inline math still renders: $z^2$.
        """#
        let result = processMarkdownParsingRanges(in: markdown)

        #expect(result.markdown.contains(#"""
        ```latex
        $x^2 + y^2 = c^2$
        ```
        """#))
        #expect(Array(result.inlineMathStorage.values) == [#"$z^2$"#])
    }

    @Test
    func testMathPreprocessingPreservesBlockDirectiveMathLiteral() async throws {
        let markdown = #"""
        @callout {
        $x^2 + y^2 = c^2$
        }

        Inline math still renders: $z^2$.
        """#
        let result = processMarkdownParsingRanges(
            in: markdown,
            requiresBlockDirectiveParsing: true
        )

        #expect(result.markdown.contains(#"""
        @callout {
        $x^2 + y^2 = c^2$
        }
        """#))
        #expect(Array(result.inlineMathStorage.values) == [#"$z^2$"#])
    }

    @Test
    func testMathPreprocessingPreservesLinkMetadataLiterals() async throws {
        let markdown = #"Read [Apple Developer](https://developer.apple.com/documentation/swift "$release$ notes") before rendering $x_y$ in the paragraph."#
        let result = processMarkdownParsingRanges(in: markdown)

        #expect(result.markdown.contains(#"https://developer.apple.com/documentation/swift"#))
        #expect(result.markdown.contains(#""$release$ notes""#))
        #expect(Array(result.inlineMathStorage.values) == [#"$x_y$"#])
    }

    @Test
    func testMathPreprocessingPreservesReferenceLinkMetadataLiterals() async throws {
        let markdown = #"""
        [Apple Developer]: https://developer.apple.com/documentation/swift/$release "$release$ notes"

        Read [Apple Developer] for more information.
        """#
        let result = processMarkdownParsingRanges(in: markdown)

        #expect(result.markdown.contains(#"[Apple Developer]: https://developer.apple.com/documentation/swift/$release "$release$ notes""#))
        #expect(result.inlineMathStorage.isEmpty)
    }

    @Test
    func testMathPreprocessingPreservesInlineCodeInLinkLabels() async throws {
        let markdown = #"Read [the `$x_y$` example](https://example.com) before rendering $a_b$ in the paragraph."#
        let result = processMarkdownParsingRanges(in: markdown)

        #expect(result.markdown.contains(#"[the `$x_y$` example]"#))
        #expect(Array(result.inlineMathStorage.values) == [#"$a_b$"#])
    }

    @Test
    func testMathPreprocessingPreservesImageLiterals() async throws {
        let markdown = #"![Google logo $asset$](https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png "Google $asset$ logo") and render $x_y$."#
        let result = processMarkdownParsingRanges(in: markdown)

        #expect(result.markdown.contains(#"![Google logo $asset$]"#))
        #expect(result.markdown.contains(#"https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"#))
        #expect(result.markdown.contains(#""Google $asset$ logo""#))
        #expect(Array(result.inlineMathStorage.values) == [#"$x_y$"#])
    }

    private func extractedMath(in markdown: String) -> [String] {
        MathParser(text: markdown).mathRepresentations.map { mathRepresentation in
            String(markdown[mathRepresentation.range])
        }
    }

    private func processMarkdownParsingRanges(
        in markdown: String,
        requiresBlockDirectiveParsing: Bool = false
    ) -> MarkdownMathPreprocessor.Result {
        MarkdownMathPreprocessor().preprocessingResult(
            for: markdown,
            requiresBlockDirectiveParsing: requiresBlockDirectiveParsing
        )
    }
}
