//
//  MarkdownUnaryView.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI
import Markdown

protocol MarkdownUnaryView: View {
    associatedtype MarkdownMarkup: Markup
    
    var markup: MarkdownMarkup { get }
}
