import MarkdownView
import SwiftUI

#Preview(traits: .markdownViewExample) {
    let markdownText = #"""
    Einstein's equation $E = mc^2$ relates energy and mass.

    ---

    The Pythagorean theorem states that \(a^2 + b^2 = c^2\).

    ---

    The Gaussian integral evaluates to:

    \[
    \int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
    \]

    ---

    A Taylor series expansion around \(a\) is:

    \begin{equation}
    f(x) = \sum_{n=0}^{\infty} \frac{f^{(n)}(a)}{n!}(x - a)^n
    \end{equation}

    ---

    The quadratic formula is:

    \begin{equation*}
    x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
    \end{equation*}
    """#

    MarkdownView(markdownText)
        .markdownMathRenderingEnabled()
        .lineSpacing(12)
        .frame(width: 500)
}
