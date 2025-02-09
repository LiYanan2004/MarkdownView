import SwiftUI
import Markdown

struct MarkdownViewRenderer: @preconcurrency MarkupVisitor {
    typealias Result = ViewContent
    
    var configuration: MarkdownView.RendererConfiguration
    
    func representedView(for document: Document) -> some View {
        var renderer = self
        return renderer.visit(document).content
    }
    
    mutating func visitDocument(_ document: Document) -> Result {
        let contents = contents(of: document)
        var paras = [Result]()
        var index = 0
        while index < contents.count {
            if contents[index].type == .text && paras.last?.type == .text {
                paras.append(Result(Text("\n\n") + contents[index].text))
            } else {
                paras.append(contents[index])
            }
            index += 1
        }
        return Result(paras, autoLayout: false)
    }
    
    mutating func defaultVisit(_ markup: Markdown.Markup) -> Result {
        Result(contents(of: markup))
    }
}
