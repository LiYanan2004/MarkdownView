//
//  MathDestination.swift
//  DemoApp
//
//  Created by LiYanan2004 on 2024/10/23.
//

import SwiftUI
import MarkdownView

struct MathDestination: View {
    var body: some View {
        VStack(alignment: .leading) {
            MarkdownView(#"""
            Einstein's famous equation $E = mc^2$ relates energy and mass.
            
            ---
            
            The Pythagorean theorem states that \(a^2 + b^2 = c^2\).
            
            ---
            
            The Gaussian integral evaluates to:
            
            \[
            \int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
            \]
            
            ---
            
            A Taylor series expansion around a point \(a\) is given by:
            
            \begin{equation}
            f(x) = \sum_{n=0}^{\infty} \frac{f^{(n)}(a)}{n!}(x - a)^n
            \end{equation}
            
            ---
            
            The quadratic formula is written as:
            
            \begin{equation*}
            x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
            \end{equation*}
            """#)
        }
        .markdownMathRenderingEnabled()
        .lineSpacing(12)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            ImageDestination()
                .frame(width: 300)
        }
    }
}
