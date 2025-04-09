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
            MarkdownView(#"This sentence uses `$` delimiters to show math inline: $\sqrt{3x-1}+(1+x)^2$"#)
            
            MarkdownView(#"""
            **The Cauchy-Schwarz Inequality**
            $$\left( \sum_{k=1}^n a_k b_k \right)^2 \leq \left( \sum_{k=1}^n a_k^2 \right) \left( \sum_{k=1}^n b_k^2 \right)$$
            """#)
        }
        .markdownMathRenderingEnabled()
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
