import MarkdownView
import SwiftUI

#Preview(traits: .markdownViewExample) {
    let markdownText = """
    | Programming Language | Year Created | Creator           | Popular Frameworks/Libraries |
    |:--------------------:|:------------:|-------------------|-------------------------------|
    | Python               | 1991         | Guido van Rossum  | Django, Flask, TensorFlow     |
    | JavaScript           | 1995         | Brendan Eich      | React, Angular, Vue.js        |
    | Java                 | 1995         | James Gosling     | Spring, Hibernate, Android    |
    | Swift                | 2014         | Apple Inc.        | SwiftUI, Vapor                |
    | C#                   | 2000         | Microsoft         | .NET, Unity                   |
    | Ruby                 | 1995         | Yukihiro Matsumoto| Ruby on Rails, Sinatra        |
    | Go                   | 2009         | Griesemer, Pike, Thompson | Gin, Echo              |
    """
    
    MarkdownView(markdownText)
}
