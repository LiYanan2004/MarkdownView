import MarkdownView
import SwiftUI

#Preview(traits: .markdownViewExample) {
    let blockQuoteTint = Color.orange
    let inlineCodeTint = Color.indigo
    let markdownText = """
    # Getting Started with **SwiftUI**

    ## SwiftUI Basics

    ### Why Choose SwiftUI?
    SwiftUI is **Apple's declarative framework** for building user interfaces across Apple platforms.

    #### Key Advantages
    - **Declarative syntax** with concise view code.
    - **Cross-platform development** for iOS, macOS, watchOS, and tvOS.

    > SwiftUI takes a lot of the complexity out of UI development.

    Use `tint` and heading styles to customize rendering.
    """

    MarkdownView(markdownText)
        .tint(blockQuoteTint, for: .blockQuote)
        .tint(inlineCodeTint, for: .inlineCodeBlock)
        .headingStyle(.secondary, for: .h2)
        .headingStyle(.tertiary, for: .h3)
        .headingStyle(.tertiary, for: .h4)
}
