//
//  TableDestination.swift
//  DemoApp
//
//  Created by LiYanan2004 on 2024/10/23.
//

import SwiftUI
import MarkdownView

struct TableDestination: View {
    var body: some View {
        MarkdownView("""
        | Programming Language | Year Created | Creator           | Popular Frameworks/Libraries |
        |:--------------------:|:------------:|-----------------|------------------------------|
        | Python               | 1991         | Guido van Rossum  | Django, Flask, TensorFlow    |
        | JavaScript           | 1995         | Brendan Eich      | React, Angular, Vue.js       |
        | Java                 | 1995         | James Gosling     | Spring, Hibernate, Android   |
        | Swift                | 2014         | Apple Inc.        | SwiftUI, Vapor               |
        | C#                   | 2000         | Microsoft         | .NET, Unity                  |
        | Ruby                 | 1995         | Yukihiro Matsumoto| Ruby on Rails, Sinatra       |
        | Go                   | 2009         | Robert Griesemer, Rob Pike, and Ken Thompson | Gin, Echo |
        """)
    }
}

#Preview {
    ScrollView {
        TableDestination()
    }
    .frame(width: 500)
}
