import MarkdownView
import SwiftUI

#Preview(traits: .markdownViewExample) {
    let markdownText = """
    # MarkdownView
    ## Heading 2
    ### Heading 3
    #### Heading 4

    __MarkdownView__ is built with `swift-markdown`.

    It supports _SVG rendering_, which is great for badge-style assets.
    """

    MarkdownView(markdownText)
}
