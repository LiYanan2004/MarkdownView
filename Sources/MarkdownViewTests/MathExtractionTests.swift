//
//  MathExtractionTests.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/9.
//

import Testing
import Markdown
@_spi(MarkdownMath) @testable import MarkdownView

@MainActor
struct MathExtractionTests {
    struct MathExtractionTestConfiguration: Sendable {
        var plainText: String
        var extractedMath: [String]
    }

    @Test(
        arguments: [
            MathExtractionTestConfiguration(
                plainText: #"delimiters to show math inline: $\sqrt{3x-1}+(1+x)^2$"#,
                extractedMath: [#"$\sqrt{3x-1}+(1+x)^2$"#]
            ),
            MathExtractionTestConfiguration(
                plainText: #"""
                **The Cauchy-Schwarz Inequality**
                $$\left( \sum_{k=1}^n a_k b_k \right)^2 \leq \left( \sum_{k=1}^n a_k^2 \right) \left( \sum_{k=1}^n b_k^2 \right)$$
                """#,
                extractedMath: [#"$$\left( \sum_{k=1}^n a_k b_k \right)^2 \leq \left( \sum_{k=1}^n a_k^2 \right) \left( \sum_{k=1}^n b_k^2 \right)$$"#]
            ),
            MathExtractionTestConfiguration(
                plainText: #"\( G_{\mu\nu} \): Einstein tensor (spacetime curvature)"#,
                extractedMath: [#"\( G_{\mu\nu} \)"#]
            ),
            MathExtractionTestConfiguration(
                plainText: #"\[ \hat{H}\psi = E\psi \quad \text{where} \quad \hat{H} = -\frac{\hbar^2}{2m}\nabla^2 + V(\mathbf{r}) \]"#,
                extractedMath: [#"\[ \hat{H}\psi = E\psi \quad \text{where} \quad \hat{H} = -\frac{\hbar^2}{2m}\nabla^2 + V(\mathbf{r}) \]"#]
            ),
            MathExtractionTestConfiguration(
                plainText: #"$(a_n)_{n \in \mathbb{N}}$ und $(b_n)_{n \in \mathbb{N}}$ sind geometrische Folgen."#,
                extractedMath: [
                    #"$(a_n)_{n \in \mathbb{N}}$"#,
                    #"$(b_n)_{n \in \mathbb{N}}$"#,
                ]
            ),
        ]
    )
    func testMathExtractionCase(
        _ configuration: MathExtractionTestConfiguration
    ) async throws {
        let parser = MathParser(text: configuration.plainText)
        let extractedMath = parser.mathRepresentations
            .map(\.range)
            .map { String(configuration.plainText[$0]) }
        #expect(extractedMath == configuration.extractedMath)
    }

    @Test
    func testMathPreprocessingProtectsInlineMathUnderscores() async throws {
        let markdown = #"$(a_n)_{n \in \mathbb{N}}$ und $(b_n)_{n \in \mathbb{N}}$ sind geometrische Folgen."#
        let preprocessor = MathPlaceholderPreprocessor()
        let result = preprocessor.process(markdown)

        #expect(result.inlineMathStorage.count == 2)
        #expect(result.displayMathStorage.isEmpty)
        #expect(Set(result.inlineMathStorage.values) == Set([
            #"$(a_n)_{n \in \mathbb{N}}$"#,
            #"$(b_n)_{n \in \mathbb{N}}$"#,
        ]))
        #expect(!result.markdown.contains("_"))
    }

    @Test
    func testMathPreprocessingPreservesInlineCodeMathLiteral() async throws {
        let markdown = #"Use `$x_y$` literally, then render $a_b$."#
        var extractor = MathFirstMarkdownViewRenderer.ParsingRangesExtractor()
        extractor.visit(
            Document(
                parsing: markdown,
                options: ParseOptions().union(.parseBlockDirectives)
            )
        )

        let preprocessor = MathPlaceholderPreprocessor()
        let result = preprocessor.process(
            markdown,
            parsableRanges: extractor.parsableRanges(in: markdown)
        )

        #expect(result.markdown.contains(#"`$x_y$`"#))
        #expect(!result.inlineMathStorage.values.contains(#"$x_y$"#))
        #expect(result.inlineMathStorage.values.contains(#"$a_b$"#))
    }
}
