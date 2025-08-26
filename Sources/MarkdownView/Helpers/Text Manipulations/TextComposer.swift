//
//  TextComposer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/22.
//

import SwiftUI

struct TextComposer {
    private var _string: String = ""
    
    var text: Text {
        Text(verbatim: _string)
    }
    private(set) var hasText: Bool = false
    
    init(@TextBuilder text: @escaping () -> Text) {
        self._string = TextComposer.resolveText(text())
    }
    
    init() {
        
    }
    
    mutating func append(_ text: Text) {
        hasText = true
        self._string += TextComposer.resolveText(text)
    }
    
    static private func resolveText(_ text: Text) -> String {
        text._resolveText(in: EnvironmentValues())
    }
}
