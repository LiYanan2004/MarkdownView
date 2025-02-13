//
//  CodeBlockTextRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/12.
//

import SwiftUI
#if canImport(Highlightr)
import Highlightr
#endif

struct CodeBlockTextRenderer: MarkdownNode2TextRenderer {
    func body(context: Context) -> Text {
        BreakTextRenderer(breakType: .hard)
            .body(context: context)
        BreakTextRenderer(breakType: .hard)
            .body(context: context)
        
        let language = if case let .codeLanguage(language) = context.node.content! {
            language
        } else {
            fatalError("Missing code language")
        }
         
        if case let .text(code) = context.node.children[0].content! {
            let processedCode: AttributedString = {
                #if canImport(Highlightr)
                let highlighter = Highlightr()!
                highlighter.setTheme(to: context.renderConfiguration.currentCodeHighlightTheme)
                if highlighter.supportedLanguages().contains(language) == true,
                    let highlighted = highlighter.highlight(code, as: language) {
                    let attributedCode = NSMutableAttributedString(
                        attributedString: highlighted
                    )
                    attributedCode.removeAttribute(.font, range: NSMakeRange(0, attributedCode.length))
                    
                    return AttributedString(attributedCode)
                } else {
                    return AttributedString(code)
                }
                #else
                return AttributedString(code)
                #endif
            }()
            
            Text(processedCode)
                .font(.callout.monospaced())
        }
        
        BreakTextRenderer(breakType: .hard)
            .body(context: context)
    }
}

/*
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct CodeBlockTextRenderer: TextRenderer {
    private func maxWidthOfTextLayout(_ layout: Text.Layout) -> CGFloat {
        var maxWidth: CGFloat = 0
        for line in layout {
            maxWidth = max(line.typographicBounds.width, maxWidth)
        }
        return maxWidth
    }
    
    private func _drawCodeBlockBackground(rect: CGRect, padding: CGFloat, in context: inout GraphicsContext) {
        context.fill(
            RoundedRectangle(cornerRadius: abs(padding))
                .path(in: rect.insetBy(dx: padding, dy: padding)),
            with: .color(.red.opacity(0.5))
        )
    }
    
    private func drawsBackgroundForCodeBlocks(layout: Text.Layout, in context: inout GraphicsContext) {
        let maxWidth: CGFloat = maxWidthOfTextLayout(layout)
        var codeBlockRect: CGRect?
        
        for line in layout {
            let firstRun = line.first
            guard let firstRun else { continue }
            
            guard firstRun.isWrappedInsideCodeBlock else {
                if let codeBlockRect {
                    _drawCodeBlockBackground(rect: codeBlockRect, padding: -6, in: &context)
                }
                codeBlockRect = nil
                continue
            }
            
            if codeBlockRect == nil {
                // Create a new background area
                codeBlockRect = CGRect(
                    origin: line.typographicBounds.rect.origin,
                    size: CGSize(
                        width: maxWidth,
                        height: line.typographicBounds.rect.height
                    )
                )
            } else {
                // Grows the height
                codeBlockRect!.size.height = line.typographicBounds.rect.maxY - codeBlockRect!.minY
            }
        }
        
        if let codeBlockRect {
            _drawCodeBlockBackground(rect: codeBlockRect, padding: -6, in: &context)
        }
    }
    
    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        drawsBackgroundForCodeBlocks(layout: layout, in: &context)
        
        for line in layout {
            context.draw(line)
        }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct CodeBlockTextAttribute: TextAttribute {}

// MARK: - Auxiliary

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
fileprivate extension Text.Layout.Run {
    var isWrappedInsideCodeBlock: Bool {
        self[CodeBlockTextAttribute.self] != nil
    }
}
*/
