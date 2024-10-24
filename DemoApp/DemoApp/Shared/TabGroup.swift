//
//  TabGroup.swift
//  DemoApp
//
//  Created by LiYanan2004 on 2024/10/24.
//

import Foundation

enum TabGroup: String, Codable, CaseIterable {
    case intro = "Intro"
    case interactive = "Try"
    case usage = "Demo"
    
    var tabs: [Tab] {
        switch self {
        case .intro:       [.overview]
        case .interactive: [.interact]
        case .usage:       [.text, .image, .todoList, .table, .customization, .blockDirective]
        }
    }
}

// MARK: - Conformance: Identifiable

extension TabGroup: Identifiable {
    var id: Self { self }
}
