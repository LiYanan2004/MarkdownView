//
//  CustomizationDestination.swift
//  DemoApp
//
//  Created by LiYanan2004 on 2024/10/24.
//

import SwiftUI
import MarkdownView

struct CustomizationDestination: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Section {
                MarkdownView(text: "# H1 title")
                    .font(.largeTitle.weight(.black), for: .h1)
            } header: {
                Text("Font").font(.headline)
            }
            
            Divider()
            
            Section {
                MarkdownView(text: "> Quote and `inline code`")
                    .tint(Color.blue, for: .blockQuote)
                    .tint(Color.red, for: .inlineCodeBlock)
            } header: {
                Text("Tint").font(.headline)
            }
        }
    }
}

#Preview {
    CustomizationDestination()
}
