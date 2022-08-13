import Markdown
import SwiftUI

extension Renderer {
    mutating func visitEmphasis(_ emphasis: Markdown.Emphasis) -> AnyView {
        var subviews = [AnyView]()
        
        for child in emphasis.children {
            subviews.append(visit(child))
        }
        
        return AnyView(ForEach(subviews.indices, id: \.self) { index in
            subviews[index].italic()
        })
    }
    
    mutating func visitStrong(_ strong: Strong) -> AnyView {
        var subviews = [AnyView]()
        for child in strong.children {
            subviews.append(visit(child))
        }
        return AnyView(ForEach(subviews.indices, id: \.self) { index in
            subviews[index].bold()
        })
    }
    
    mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> AnyView {
        var subviews = [AnyView]()
        for child in strikethrough.children {
            subviews.append(visit(child))
        }
        return AnyView(ForEach(subviews.indices, id: \.self) { index in
            subviews[index].strikethrough()
        })
    }
    
    mutating func visitHeading(_ heading: Heading) -> AnyView {
        var subviews = [AnyView]()
        for child in heading.children {
            subviews.append(visit(child))
        }
        let fontStyle: Font.TextStyle
        switch heading.level {
        case 1: fontStyle = .largeTitle
        case 2: fontStyle = .title
        case 3: fontStyle = .title2
        case 4: fontStyle = .title3
        case 5: fontStyle = .headline
        case 6: fontStyle = .body
        default: fontStyle = .body
        }
        return AnyView(FlexibleLayout {
            ForEach(subviews.indices, id: \.self) { index in
                subviews[index].font(.system(fontStyle, weight: .bold))
            }
        }.tag(heading.plainText))
    }
}
