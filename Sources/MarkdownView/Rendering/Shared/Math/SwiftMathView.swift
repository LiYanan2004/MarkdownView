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

    @Environment(\.colorScheme) private var colorScheme

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

    private var textColor: MTColor {
        MTColor(colorScheme == .dark ? Color.white : Color.black)
    }
    
    var body: some View {
        SwiftMathPlatformView(
            equation: equation,
            fontSize: font.asPlatformFont.pointSize,
            labelMode: labelMode,
            textAlignment: textAlignment,
            textColor: textColor
        )
        .alignmentGuide(.firstTextBaseline) { dimensions in
            font.asPlatformFont.ascender
        }
        .alignmentGuide(.lastTextBaseline) { dimensions in
            font.asPlatformFont.ascender
        }
    }
}

fileprivate struct SwiftMathPlatformView {
    var equation: String
    var fontSize: CGFloat
    var labelMode: MTMathUILabelMode
    var textAlignment: MTTextAlignment
    var textColor: MTColor
    
    @MainActor
    private func apply(to mathLabel: MTMathUILabel) {
        mathLabel.latex = equation
        mathLabel.fontSize = fontSize
        mathLabel.labelMode = labelMode
        mathLabel.textAlignment = textAlignment
        mathLabel.textColor = textColor
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
}

#endif
