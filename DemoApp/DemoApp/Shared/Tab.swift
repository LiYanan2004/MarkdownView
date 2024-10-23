//
//  Tab.swift
//  DemoApp
//
//  Created by LiYanan2004 on 2024/10/23.
//

import Foundation
import SwiftUI

enum Tab: String, CaseIterable {
    case overview
    
    var name: String {
        switch self {
        case .overview:
            return "Overview"
        }
    }
}

// MARK: - Link

extension Tab {
    struct TabLink: View {
        let tab: Tab
        var body: some View {
            NavigationLink(tab.name, value: tab)
        }
    }
    
    /// A navigation link view to the destination view.
    var link: TabLink { .init(tab: self) }
}

// MARK: - Destination

extension Tab {
    struct TabDestination: View {
        let tab: Tab
        var body: some View {
            ScrollView {
                switch tab {
                case .overview:
                    OverviewDestination()
                }
            }
        }
    }
    
    /// A navigation detail view of this tab.
    var destination: TabDestination { .init(tab: self) }
}

// MARK: - Conformance: Identifiable

extension Tab: Identifiable {
    var id: String { name }
}
