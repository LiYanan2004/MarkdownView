import Markdown
import SwiftUI

// MARK: - Code Block

extension Renderer {
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> Result {
        Result {
            #if canImport(Highlightr)
            HighlightedCodeBlock(
                language: codeBlock.language,
                code: codeBlock.code,
                theme: configuration.codeBlockTheme
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
