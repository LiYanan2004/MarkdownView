//
//  TextComposer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/22.
//

import SwiftUI

struct TextComposer {
    private(set) var text: Text
    private(set) var hasText: Bool = false
    
    init(@TextBuilder text: @escaping () -> Text) {
        self.text = text()
    }
    
    init() {
        self.text = Text("")
    }
    
    mutating func append(_ text: Text) {
        hasText = true
        self.text = self.text + text
    }
}
