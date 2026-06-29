//
//  MarkdownRendererKind.swift
//  Examples
//
//

enum MarkdownRendererKind: CaseIterable, Hashable, Identifiable {
    #if os(iOS) || os(macOS)
    case markdownText
    #endif
    case markdownView

    var id: Self {
        self
    }

    var title: String {
        switch self {
        #if os(iOS) || os(macOS)
        case .markdownText:
            "MarkdownText"
        #endif
        case .markdownView:
            "MarkdownView"
        }
    }
}
