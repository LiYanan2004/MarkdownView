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
    @Test(
        "Extracts dollar-delimited inline math",
        .tags(.math, .mathExtraction)
    )
    func testExtractsDollarDelimitedInlineMath() async throws {
        let markdown = #"""
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. The sample mean is $\bar{x} = \frac{1}{n}\sum_{i=1}^{n}x_i$, and the report continues with ordinary prose.
        """#

        #expect(MarkdownViewTestSupport.extractedMathRepresentations(in: markdown) == [
            #"$\bar{x} = \frac{1}{n}\sum_{i=1}^{n}x_i$"#,
        ])
    }

    @Test(
        "Extracts parenthesis-delimited inline math",
        .tags(.math, .mathExtraction)
    )
    func testExtractsParenthesesDelimitedInlineMath() async throws {
        let markdown = #"""
        Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. The confidence interval \( \hat{p} \pm z_{\alpha/2}\sqrt{\frac{\hat{p}(1-\hat{p})}{n}} \) appears inline.
        """#

        #expect(MarkdownViewTestSupport.extractedMathRepresentations(in: markdown) == [
            #"\( \hat{p} \pm z_{\alpha/2}\sqrt{\frac{\hat{p}(1-\hat{p})}{n}} \)"#,
        ])
    }

    @Test(
        "Extracts dollar-delimited display math",
        .tags(.math, .mathExtraction)
    )
    func testExtractsDollarDelimitedDisplayMath() async throws {
        let markdown = #"""
        Pellentesque habitant morbi tristique senectus et netus et malesuada fames.

        $$\int_{0}^{1} x^2\,dx = \frac{1}{3}$$

        Donec ullamcorper nulla non metus auctor fringilla.
        """#

        #expect(MarkdownViewTestSupport.extractedMathRepresentations(in: markdown) == [
            #"$$\int_{0}^{1} x^2\,dx = \frac{1}{3}$$"#,
        ])
    }

    @Test(
        "Extracts bracket-delimited display math",
        .tags(.math, .mathExtraction)
    )
    func testExtractsBracketDelimitedDisplayMath() async throws {
        let markdown = #"""
        Cras mattis consectetur purus sit amet fermentum.

        \[
        \nabla \cdot \mathbf{E} = \frac{\rho}{\varepsilon_0}
        \]

        Integer posuere erat a ante venenatis dapibus.
        """#

        #expect(MarkdownViewTestSupport.extractedMathRepresentations(in: markdown) == [
            #"""
            \[
            \nabla \cdot \mathbf{E} = \frac{\rho}{\varepsilon_0}
            \]
            """#,
        ])
    }

    @Test(
        "Extracts named equation environments",
        .tags(.math, .mathExtraction)
    )
    func testExtractsNamedEquation() async throws {
        let markdown = #"""
        Maecenas sed diam eget risus varius blandit sit amet non magna.

        \begin{equation}
        E = mc^2
        \end{equation}

        Etiam porta sem malesuada magna mollis euismod.
        """#

        #expect(MarkdownViewTestSupport.extractedMathRepresentations(in: markdown) == [
            #"""
            \begin{equation}
            E = mc^2
            \end{equation}
            """#,
        ])
    }

    @Test(
        "Extracts unnumbered named equation environments",
        .tags(.math, .mathExtraction)
    )
    func testExtractsUnnumberedNamedEquation() async throws {
        let markdown = #"""
        Nullam id dolor id nibh ultricies vehicula ut id elit.

        \begin{equation*}
        a^2 + b^2 = c^2
        \end{equation*}

        Aenean lacinia bibendum nulla sed consectetur.
        """#

        #expect(MarkdownViewTestSupport.extractedMathRepresentations(in: markdown) == [
            #"""
            \begin{equation*}
            a^2 + b^2 = c^2
            \end{equation*}
            """#,
        ])
    }

    @Test(
        "Extracts supported standalone SwiftMath environments",
        .tags(.math, .mathExtraction),
        arguments: [
            "matrix", "pmatrix", "bmatrix", "Bmatrix", "vmatrix", "Vmatrix",
            "eqalign", "split", "aligned", "displaylines", "gather", "eqnarray", "cases",
        ]
    )
    func extractsStandaloneSwiftMathEnvironment(environmentName: String) {
        let environment = "\\begin{\(environmentName)}x & y\\end{\(environmentName)}"

        #expect(MarkdownViewTestSupport.extractedMathRepresentations(in: "Display math: \(environment)") == [environment])
    }

    @Test(
        "Extracts an outer environment that contains a nested environment",
        .tags(.math, .mathExtraction)
    )
    func extractsOuterEnvironmentContainingNestedEnvironment() {
        let markdown = #"\begin{gather}x = \begin{pmatrix}1 & 2\end{pmatrix}\end{gather}"#

        #expect(MarkdownViewTestSupport.extractedMathRepresentations(in: markdown) == [markdown])
    }

    @Test(
        "Ignores unsupported standalone environments",
        .tags(.math, .mathExtraction)
    )
    func ignoresUnsupportedStandaloneEnvironment() {
        let markdown = #"\begin{document}ordinary text\end{document}"#

        #expect(MarkdownViewTestSupport.extractedMathRepresentations(in: markdown).isEmpty)
    }

    @Test(
        "Recognizes a delimiter after an even number of backslashes",
        .tags(.math, .mathExtraction)
    )
    func recognizesDelimiterFollowingAnEvenNumberOfBackslashes() {
        let markdown = #"Text ends with a command break \\$x$"#

        #expect(MarkdownViewTestSupport.extractedMathRepresentations(in: markdown) == [#"$x$"#])
    }

    @Test(
        "Ignores a delimiter after an odd number of backslashes",
        .tags(.math, .mathExtraction)
    )
    func ignoresDelimiterFollowingAnOddNumberOfBackslashes() {
        let markdown = #"The delimiter is escaped: \$x$"#

        #expect(MarkdownViewTestSupport.extractedMathRepresentations(in: markdown).isEmpty)
    }

    @Test(
        "Ignores unterminated inline dollar math before a later completed expression",
        .tags(.math, .mathExtraction)
    )
    func ignoresUnterminatedInlineDollarMathBeforeLaterCompletedExpression() {
        let markdown = #"Price moved from $73.00 and the valid equation is $x$."#

        #expect(MarkdownViewTestSupport.extractedMathRepresentations(in: markdown) == [#"$x$"#])
    }

    @Test(
        "Ignores unterminated bracket display math during streaming",
        .tags(.math, .mathPreprocessing, .streaming)
    )
    func ignoresUnterminatedBracketDisplayMathDuringStreaming() {
        let markdown = #"""
        \[
        E = mc^2
        """#

        let result = MarkdownViewTestSupport.makeMathPreprocessingResult(for: markdown)

        #expect(result.markdown == markdown)
        #expect(result.displayMathStorage.isEmpty)
        #expect(result.inlineMathStorage.isEmpty)
    }

    @Test(
        "Protects underscores inside inline math",
        .tags(.math, .mathPreprocessing)
    )
    func testMathPreprocessingProtectsInlineMathUnderscores() async throws {
        let result = MarkdownViewTestSupport.makeMathPreprocessingResult(for: #"Lorem ipsum dolor sit amet, $(a_n)_{n \in \mathbb{N}}$ and $(b_n)_{n \in \mathbb{N}}$ are both geometric sequences."#)

        #expect(result.inlineMathStorage.count == 2)
        #expect(result.displayMathStorage.isEmpty)
        #expect(Set(result.inlineMathStorage.values) == Set([
            #"$(a_n)_{n \in \mathbb{N}}$"#,
            #"$(b_n)_{n \in \mathbb{N}}$"#,
        ]))
        #expect(!result.markdown.contains("_"))
    }

    @Test(
        "Returns processed Markdown with inline placeholders",
        .tags(.math, .mathPreprocessing)
    )
    func testPreprocessReturnsProcessedMarkdown() async throws {
        let markdown = #"The sample mean is $\bar{x}$."#
        let processedMarkdown = MarkdownMathPreprocessor().preprocess(markdown)

        #expect(processedMarkdown.contains("markdownview-math(inline:"))
        #expect(!processedMarkdown.contains(#"$\bar{x}$"#))
    }

    @Test(
        "Leaves plain text unchanged when no math is present",
        .tags(.math, .mathPreprocessing)
    )
    func testMathPreprocessingLeavesPlainTextUntouched() async throws {
        let markdown = "Plain prose without any supported math delimiters."
        let result = MarkdownViewTestSupport.makeMathPreprocessingResult(for: markdown)

        #expect(result.markdown == markdown)
        #expect(result.displayMathStorage.isEmpty)
        #expect(result.inlineMathStorage.isEmpty)
    }

    @Test(
        "Leaves hard-line-break text unchanged when no math is present",
        .tags(.math, .mathPreprocessing)
    )
    func testMathPreprocessingLeavesHardLineBreakTextUntouched() async throws {
        let markdown = #"""
        Hard line break\
        starts a new rendered line.
        """#
        let result = MarkdownViewTestSupport.makeMathPreprocessingResult(for: markdown)

        #expect(result.markdown == markdown)
        #expect(result.displayMathStorage.isEmpty)
        #expect(result.inlineMathStorage.isEmpty)
    }

    @Test(
        "Stores dollar display math with delimiters",
        .tags(.math, .mathPreprocessing)
    )
    func testMathPreprocessingStoresDollarDisplayMathWithDelimiters() async throws {
        let markdown = #"""
        Display math:

        $$
        \int_0^1 x^2\,dx = \frac{1}{3}
        $$
        """#
        let result = MarkdownViewTestSupport.makeMathPreprocessingResult(for: markdown)

        #expect(
            result.displayMathStorage.values.first == #"""
            $$
            \int_0^1 x^2\,dx = \frac{1}{3}
            $$
            """#
        )
        #expect(result.markdown.contains("markdownview-math(display:"))
    }

    @Test(
        "Stores bracket display math with delimiters",
        .tags(.math, .mathPreprocessing)
    )
    func testMathPreprocessingStoresBracketDisplayMathWithDelimiters() async throws {
        let markdown = #"""
        \[
        \nabla \cdot \mathbf{E} = \frac{\rho}{\varepsilon_0}
        \]
        """#
        let result = MarkdownViewTestSupport.makeMathPreprocessingResult(for: markdown)

        #expect(
            result.displayMathStorage.values.first == #"""
            \[
            \nabla \cdot \mathbf{E} = \frac{\rho}{\varepsilon_0}
            \]
            """#
        )
    }

    @Test(
        "Keeps an existing display-math identifier when appending trailing content",
        .tags(.math, .mathPreprocessing, .streaming)
    )
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

        let previousResult = MarkdownViewTestSupport.makeMathPreprocessingResult(for: previousMarkdown)
        let appendedResult = MarkdownViewTestSupport.makeMathPreprocessingResult(for: appendedMarkdown)

        #expect(
            Set(previousResult.displayMathStorage.keys)
                .isSubset(of: Set(appendedResult.displayMathStorage.keys))
        )
    }

    @Test(
        "Uses unified parsable markers for inline and display placeholders",
        .tags(.math, .mathPreprocessing)
    )
    func testMathPreprocessingUsesUnifiedParsableMarkers() async throws {
        let markdown = #"""
        Inline math: $x$

        $$
        y
        $$
        """#
        let result = MarkdownViewTestSupport.makeMathPreprocessingResult(for: markdown)

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

    @Test(
        "Finds a display placeholder followed by trailing inline text",
        .tags(.math, .mathPreprocessing)
    )
    func testMathPreprocessingFindsDisplayPlaceholderWithTrailingInlineText() async throws {
        let markdown = #"""
        1. **Sum of a Geometric Series**:
            \[ S_n = a \frac{1-r^n}{1-r} \] (for \( r \neq 1 \))
        """#
        let result = MarkdownViewTestSupport.makeMathPreprocessingResult(for: markdown)
        let placeholderSegments = MarkdownMathPreprocessor.placeholderSegments(in: result.markdown)

        #expect(result.displayMathStorage.count == 1)
        #expect(result.inlineMathStorage.count == 1)
        #expect(placeholderSegments.map(\.match.kind) == [.display, .inline])
    }

    @Test(
        "Preserves escaped bracket punctuation outside math",
        .tags(.math, .mathPreprocessing)
    )
    func testMathPreprocessingPreservesEscapedBracketPunctuation() async throws {
        let markdown = #"Escaped punctuation: \*literal asterisks\*, \[literal brackets\], and \`literal backticks\`."#
        let result = MarkdownViewTestSupport.makeMathPreprocessingResult(for: markdown)

        #expect(result.markdown == markdown)
        #expect(result.displayMathStorage.isEmpty)
        #expect(result.inlineMathStorage.isEmpty)
    }

    @Test(
        "Extracts indented bracket-delimited display math",
        .tags(.math, .mathExtraction)
    )
    func testExtractsIndentedBracketDelimitedDisplayMath() async throws {
        let markdown = #"""
        Introductory text.

            \[
            E = mc^2
            \]
        """#

        #expect(MarkdownViewTestSupport.extractedMathRepresentations(in: markdown) == [
            #"""
            \[
                E = mc^2
                \]
            """#,
        ])
    }

    @Test(
        "Preserves inline-code math literals",
        .tags(.math, .mathPreprocessing)
    )
    func testMathPreprocessingPreservesInlineCodeMathLiteral() async throws {
        let markdown = #"Lorem ipsum keeps `$x_y$` as source text while rendering $a_b$ in the same sentence."#
        let result = MarkdownViewTestSupport.makeMathPreprocessingResult(for: markdown)

        #expect(result.markdown.contains(#"`$x_y$`"#))
        #expect(Array(result.inlineMathStorage.values) == [#"$a_b$"#])
    }

    @Test(
        "Preserves fenced code-block math literals",
        .tags(.math, .mathPreprocessing)
    )
    func testMathPreprocessingPreservesFencedCodeBlockMathLiteral() async throws {
        let markdown = #"""
        ```latex
        $x^2 + y^2 = c^2$
        ```

        Inline math still renders: $z^2$.
        """#
        let result = MarkdownViewTestSupport.makeMathPreprocessingResult(for: markdown)

        #expect(result.markdown.contains(#"""
        ```latex
        $x^2 + y^2 = c^2$
        ```
        """#))
        #expect(Array(result.inlineMathStorage.values) == [#"$z^2$"#])
    }

    @Test(
        "Preserves block-directive math literals",
        .tags(.math, .mathPreprocessing, .blockDirectives)
    )
    func testMathPreprocessingPreservesBlockDirectiveMathLiteral() async throws {
        let markdown = #"""
        @callout {
        $x^2 + y^2 = c^2$
        }

        Inline math still renders: $z^2$.
        """#
        let result = MarkdownViewTestSupport.makeMathPreprocessingResult(
            for: markdown,
            requiresBlockDirectiveParsing: true
        )

        #expect(result.markdown.contains(#"""
        @callout {
        $x^2 + y^2 = c^2$
        }
        """#))
        #expect(Array(result.inlineMathStorage.values) == [#"$z^2$"#])
    }

    @Test(
        "Preserves link metadata literals",
        .tags(.math, .mathPreprocessing, .links)
    )
    func testMathPreprocessingPreservesLinkMetadataLiterals() async throws {
        let markdown = #"Read [Apple Developer](https://developer.apple.com/documentation/swift "$release$ notes") before rendering $x_y$ in the paragraph."#
        let result = MarkdownViewTestSupport.makeMathPreprocessingResult(for: markdown)

        #expect(result.markdown.contains(#"https://developer.apple.com/documentation/swift"#))
        #expect(result.markdown.contains(#""$release$ notes""#))
        #expect(Array(result.inlineMathStorage.values) == [#"$x_y$"#])
    }

    @Test(
        "Preserves reference-link metadata literals",
        .tags(.math, .mathPreprocessing, .links)
    )
    func testMathPreprocessingPreservesReferenceLinkMetadataLiterals() async throws {
        let markdown = #"""
        [Apple Developer]: https://developer.apple.com/documentation/swift/$release "$release$ notes"

        Read [Apple Developer] for more information.
        """#
        let result = MarkdownViewTestSupport.makeMathPreprocessingResult(for: markdown)

        #expect(result.markdown.contains(#"[Apple Developer]: https://developer.apple.com/documentation/swift/$release "$release$ notes""#))
        #expect(result.inlineMathStorage.isEmpty)
    }

    @Test(
        "Preserves inline code inside link labels",
        .tags(.math, .mathPreprocessing, .links)
    )
    func testMathPreprocessingPreservesInlineCodeInLinkLabels() async throws {
        let markdown = #"Read [the `$x_y$` example](https://example.com) before rendering $a_b$ in the paragraph."#
        let result = MarkdownViewTestSupport.makeMathPreprocessingResult(for: markdown)

        #expect(result.markdown.contains(#"[the `$x_y$` example]"#))
        #expect(Array(result.inlineMathStorage.values) == [#"$a_b$"#])
    }

    @Test(
        "Preserves image literals",
        .tags(.math, .mathPreprocessing, .attachments)
    )
    func testMathPreprocessingPreservesImageLiterals() async throws {
        let markdown = #"![Google logo $asset$](https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png "Google $asset$ logo") and render $x_y$."#
        let result = MarkdownViewTestSupport.makeMathPreprocessingResult(for: markdown)

        #expect(result.markdown.contains(#"![Google logo $asset$]"#))
        #expect(result.markdown.contains(#"https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"#))
        #expect(result.markdown.contains(#""Google $asset$ logo""#))
        #expect(Array(result.inlineMathStorage.values) == [#"$x_y$"#])
    }

}
