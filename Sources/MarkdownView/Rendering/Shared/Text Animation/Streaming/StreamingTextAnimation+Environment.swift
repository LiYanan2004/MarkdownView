//
//  StreamingTextAnimation+Environment.swift
//  MarkdownView
//
//  Created by Phineas Guo on 2026/7/15.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var streamingTextAnimation: (any StreamingTextAnimation)? = nil
}
