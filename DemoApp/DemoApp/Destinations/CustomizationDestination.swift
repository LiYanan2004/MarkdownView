//
//  CustomizationDestination.swift
//  DemoApp
//
//  Created by LiYanan2004 on 2024/10/24.
//

import SwiftUI
import MarkdownView

struct CustomizationDestination: View {
    @State private var quoteTint = Color.accentColor
    @State private var inlineCodeTint = Color.accentColor
    @State private var hiraricalTint = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 20) {
                ColorPicker("Quote Block Tint", selection: $quoteTint)
                ColorPicker("Inline Code Tint", selection: $inlineCodeTint)
                Toggle("Hirarical Tint", isOn: $hiraricalTint)
            }
            
            MarkdownView(text: """
            # Getting Started with **SwiftUI**
            
            ## SwiftUI Basics
            
            ### Why Choose SwiftUI?
            SwiftUI is **Apple's declarative framework** for building user interfaces across all Apple platforms. It provides a clean and expressive syntax, making UI development more intuitive.
            
            #### Key Advantages of SwiftUI
            - **Declarative Syntax**: Write what you want to achieve, and SwiftUI handles the rest.
            - **Cross-Platform**: Build interfaces for iOS, macOS, watchOS, and tvOS with a single codebase.
            
            ## Example Code Block
            
            ```swift
            // SwiftUI code snippet
            import SwiftUI
            
            struct ContentView: View {
                var body: some View {
                    VStack {
                        Text("Hello, SwiftUI!")
                            .font(.largeTitle)
                            .padding()
                        Button("Click Me") {
                            print("Button tapped!")
                        }
                    }
                }
            }
            ```
            
            The example above shows how **SwiftUI** leverages declarative code to create a simple interface with a `Text` view and a `Button`.
            
            ## Highlighting Quotes
            
            > "SwiftUI takes a lot of the complexity out of UI development, making it easier for developers to focus on building great apps."  
            > — Apple Developer
            
            ## Data Representation with Tables
            
            SwiftUI makes it easy to present structured data using lists and tables. Here's an example table explaining SwiftUI's components:
            
            | **Component**    | **Description**                             |
            |------------------|---------------------------------------------|
            | Views            | Basic building blocks like `Text` or `Image`.|
            | Layout Containers| Structures like `VStack`, `HStack`, `ZStack`.|
            | Modifiers        | Chainable functions to style or configure views.|
            """)
            .foregroundStyle(hiraricalTint ? .tertiary : .primary)
        }
        .tint(quoteTint, for: .blockQuote)
        .tint(inlineCodeTint, for: .inlineCodeBlock)
        .foregroundStyle(hiraricalTint ? .secondary : .primary, for: .h2)
        .foregroundStyle(hiraricalTint ? .tertiary : .primary, for: .h3)
        .foregroundStyle(hiraricalTint ? .tertiary : .primary, for: .h4)
    }
}

#Preview {
    ScrollView {
        CustomizationDestination()
            .scenePadding()
    }
}
