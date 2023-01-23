import Markdown
import SwiftUI

extension Renderer {
    mutating func visitEmphasis(_ emphasis: Markdown.Emphasis) -> Result {
        var text = [SwiftUI.Text]()
        for child in emphasis.children {
            text.append(visit(child).text.italic())
        }
        return Result(text)
    }
    
    mutating func visitStrong(_ strong: Strong) -> Result {
        var text = [SwiftUI.Text]()
        for child in strong.children {
            text.append(visit(child).text.bold())
        }
        return Result(text)
    }
    
    mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> Result {
        var text = [SwiftUI.Text]()
        for child in strikethrough.children {
            text.append(visit(child).text.strikethrough())
        }
        return Result(text)
    }
    
    mutating func visitHeading(_ heading: Heading) -> Result {
        let provider = configuration.fontProvider
        let font: Font
        switch heading.level {
        case 1: font = provider.h1
        case 2: font = provider.h2
        case 3: font = provider.h3
        case 4: font = provider.h4
        case 5: font = provider.h5
        case 6: font = provider.h6
        default: font = provider.body
        }
        
        var text = [SwiftUI.Text]()
        // Append newline based on whether it's the beginning of the text.
        if !heading.root.children.starts(with: [heading], by: { markup, heading in
            markup.isIdentical(to: heading)
        }) {
            text.append(SwiftUI.Text("\n").font(font))
        }
        for child in heading.children {
            text.append(visit(child).text.font(font))
        }
        return Result(text)
    }
}
