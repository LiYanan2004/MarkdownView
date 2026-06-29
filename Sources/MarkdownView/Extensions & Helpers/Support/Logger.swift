//
//  Logger.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/3/26.
//

import OSLog

let logger = Logger(
    subsystem: "com.liyanan2004.MarkdownView",
    category: "Internal"
)

extension Logger {
    static let runtime = Logger(subsystem: "com.apple.runtime-issues", category: "MarkdownView")
    static let streaming = Logger(subsystem: "com.liyanan2004.MarkdownView", category: "Streaming")
}
