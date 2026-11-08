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
        let fontSize = font.asPlatformFont.pointSize
        if let metrics = SwiftMathTypesetting.metrics(
            for: equation,
            fontSize: fontSize,
            labelMode: labelMode
        ) {
            let mathView = SwiftMathPlatformView(
                equation: equation,
                fontSize: fontSize,
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
                .alignmentGuide(.firstTextBaseline) { _ in metrics.ascent }
                .alignmentGuide(.lastTextBaseline) { _ in metrics.ascent }
        } else {
            Text(verbatim: latex)
                .font(Font(font.asPlatformFont as CTFont))
        }
    }
}

@MainActor
enum SwiftMathTypesetting {
    struct Metrics: Equatable {
        var ascent: CGFloat
        var width: CGFloat
    }

    private final class Entry: NSObject {
        let metrics: Metrics?
        init(_ metrics: Metrics?) { self.metrics = metrics }
    }

    private static let cache = NSCache<NSString, Entry>()

    static func metrics(
        for equation: String,
        fontSize: CGFloat,
        labelMode: MTMathUILabelMode
    ) -> Metrics? {
        let key = "\(labelMode == .display ? "d" : "t")|\(fontSize)|\(equation)" as NSString
        if let entry = cache.object(forKey: key) {
            return entry.metrics
        }
        let metrics = measure(equation, fontSize: fontSize, labelMode: labelMode)
        cache.setObject(Entry(metrics), forKey: key)
        return metrics
    }

    private static func measure(
        _ equation: String,
        fontSize: CGFloat,
        labelMode: MTMathUILabelMode
    ) -> Metrics? {
        // SwiftMath draws a character its font lacks as nothing
        guard equation.unicodeScalars.allSatisfy({ $0.isASCII || hasGlyph($0) }) else {
            return nil
        }
        return typeset(equation, fontSize: fontSize, labelMode: labelMode)
    }

    private static var glyphs: [Unicode.Scalar: Bool] = [:]

    private static func hasGlyph(_ scalar: Unicode.Scalar) -> Bool {
        if let known = glyphs[scalar] {
            return known
        }
        let drawn = CharacterSet.whitespacesAndNewlines.contains(scalar)
            || (typeset(#"\text{"# + String(scalar) + "}", fontSize: 20, labelMode: .text)?.width ?? 0) > 0
        glyphs[scalar] = drawn
        return drawn
    }

    private static func typeset(
        _ equation: String,
        fontSize: CGFloat,
        labelMode: MTMathUILabelMode
    ) -> Metrics? {
        let label = MTMathUILabel()
        label.displayErrorInline = false
        label.latex = equation
        label.fontSize = fontSize
        label.labelMode = labelMode
        guard label.error == nil else {
            return nil
        }
        label.frame = CGRect(origin: .zero, size: label.intrinsicContentSize)
        #if canImport(UIKit)
        label.layoutIfNeeded()
        #else
        label.layoutSubtreeIfNeeded()
        #endif
        return label.displayList.map { Metrics(ascent: $0.ascent, width: $0.width) }
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
