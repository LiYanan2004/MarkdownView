import Markdown
import SwiftUI
#if canImport(Highlightr)
@preconcurrency import Highlightr
#endif

extension MarkdownViewRenderer {
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> Result {
        Result {
            #if canImport(Highlightr)
            HighlightedCodeBlock(
                language: codeBlock.language,
                code: codeBlock.code
            )
            #else
            SwiftUI.Text(codeBlock.code)
            #endif
        }
    }
    
    func visitHTMLBlock(_ html: HTMLBlock) -> Result {
        Result {
            SwiftUI.Text(html.rawHTML)
        }
    }
}
