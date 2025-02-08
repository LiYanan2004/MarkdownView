import SwiftUI
import Markdown

struct Renderer: @preconcurrency MarkupVisitor {
    typealias Result = ViewContent
    
    var text: String
    var configuration: MarkdownView.RendererConfiguration
    
    var blockDirectiveRenderer: BlockDirectiveRenderer
    var imageRenderer: ImageRenderer
    
    mutating func representedView(options: ParseOptions) -> AnyView {
        visit(Document(parsing: text, options: options)).content.eraseToAnyView()
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
