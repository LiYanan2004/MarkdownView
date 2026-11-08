//
//  SwiftMathView.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/21.
//

#if ENABLE_MATH_RENDERING

import SwiftMath
import SwiftUI

struct SwiftMathView: View {
    var latex: String
    var font: any CustomCTFontConvertible
    var labelMode: MTMathUILabelMode
    var textAlignment: MTTextAlignment

    private var equation: String {
        guard let mathRepresentation = MathParser(text: latex).mathRepresentations.first,
              mathRepresentation.range == latex.startIndex..<latex.endIndex,
              !mathRepresentation.kind.preservesTerminatorsWhenRendering else {
            return latex
        }

        let contentStartIndex = latex.index(
            mathRepresentation.range.lowerBound,
            offsetBy: mathRepresentation.kind.leftTerminator.count
        )
        let contentEndIndex = latex.index(
            mathRepresentation.range.upperBound,
            offsetBy: -mathRepresentation.kind.rightTerminator.count
        )
        return String(latex[contentStartIndex..<contentEndIndex])
    }

    var body: some View {
        let mathView = SwiftMathPlatformView(
            equation: equation,
            fontSize: font.asPlatformFont.pointSize,
            labelMode: labelMode,
            textAlignment: textAlignment
        )

        mathView
            .hidden()
            .overlay {
                Rectangle()
                    .fill(.foreground)
                    .mask { mathView.glyphMask }
                    .allowsHitTesting(false)
            }
            .alignmentGuide(.firstTextBaseline) { dimensions in
                font.asPlatformFont.ascender
            }
            .alignmentGuide(.lastTextBaseline) { dimensions in
                font.asPlatformFont.ascender
            }
    }
}

@MainActor
fileprivate struct SwiftMathPlatformView {
    var equation: String
    var fontSize: CGFloat
    var labelMode: MTMathUILabelMode
    var textAlignment: MTTextAlignment
    
    var glyphMask: some View {
        let mathLabel = MTMathUILabel()
        apply(to: mathLabel)
        #if canImport(UIKit)
        let size = mathLabel.intrinsicContentSize
        mathLabel.frame.size = size
        mathLabel.layoutIfNeeded()
        #elseif canImport(AppKit)
        let size = mathLabel.fittingSize
        mathLabel.frame.size = size
        mathLabel.layoutSubtreeIfNeeded()
        #endif
        let displayList = mathLabel.displayList

        return Canvas { context, size in
            context.withCGContext { graphicsContext in
                graphicsContext.translateBy(x: 0, y: size.height)
                graphicsContext.scaleBy(x: 1, y: -1)
                displayList?.draw(graphicsContext)
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private func apply(to mathLabel: MTMathUILabel) {
        mathLabel.latex = equation
        mathLabel.fontSize = fontSize
        mathLabel.labelMode = labelMode
        mathLabel.textAlignment = textAlignment
        mathLabel.textColor = .black
        mathLabel.displayErrorInline = false
    }
}

#if canImport(UIKit)

extension SwiftMathPlatformView: UIViewRepresentable {
    func makeUIView(context: Context) -> MTMathUILabel {
        let mathLabel = MTMathUILabel()
        mathLabel.setContentHuggingPriority(.required, for: .vertical)
        mathLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        return mathLabel
    }

    func updateUIView(_ mathLabel: MTMathUILabel, context: Context) {
        apply(to: mathLabel)
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView mathLabel: MTMathUILabel,
        context: Context
    ) -> CGSize? {
        mathLabel.intrinsicContentSize
    }
}

#elseif canImport(AppKit)

extension SwiftMathPlatformView: NSViewRepresentable {
    func makeNSView(context: Context) -> MTMathUILabel {
        let mathLabel = MTMathUILabel()
        mathLabel.setContentHuggingPriority(.required, for: .vertical)
        mathLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        return mathLabel
    }

    func updateNSView(_ mathLabel: MTMathUILabel, context: Context) {
        apply(to: mathLabel)
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        nsView mathLabel: MTMathUILabel,
        context: Context
    ) -> CGSize? {
        mathLabel.fittingSize
    }
}

#endif

#Preview {
    HStack(alignment: .firstTextBaseline) {
        Text("Hello World: ")
        SwiftMathView(
            latex: #"\(\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}\)"#,
            font: PlatformFont.preferredFont(forTextStyle: .body),
            labelMode: .text,
            textAlignment: .left
        )
    }
    .foregroundStyle(.red)
}

#Preview("Gradient foreground") {
    SwiftMathView(
        latex: #"\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}"#,
        font: PlatformFont.preferredFont(forTextStyle: .body),
        labelMode: .display,
        textAlignment: .center
    )
    .foregroundStyle(.linearGradient(colors: [.red, .blue], startPoint: .leading, endPoint: .trailing))
}

#endif
