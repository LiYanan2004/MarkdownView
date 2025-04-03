//
//  ContentView.swift
//  DemoApp
//
//  Created by LiYanan2004 on 2024/10/23.
//

import SwiftUI
import MarkdownView

struct ContentView: View {
    @State private var selection: Tab? = .overview
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.doubleColumn)) {
            List(selection: $selection) {
                ForEach(TabGroup.allCases) { group in
                    Section {
                        ForEach(group.tabs) { tab in
                            tab.link
                        }
                    } header: {
                        Text(group.rawValue)
                    }
                }
            }
            .listStyle(.sidebar)
        } detail: {
            if let selection {
                selection.destination
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    ContentView()
}
