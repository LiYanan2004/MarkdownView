//
//  MathExtractionTests.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/9.
//

import Testing
@testable import MarkdownView

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
        ]
    )
    func testMathExtractionCase(
        _ configuration: MathExtractionTestConfiguration
    ) async throws {
        let mathRenderer = InlineMathOrTextRenderer(text: configuration.plainText)
        let extractedMath = mathRenderer.mathRanges
            .map { String(configuration.plainText[$0]) }
        #expect(extractedMath == configuration.extractedMath)
    }
}
