//
//  ExampleMarkdown.swift
//  Examples
//

enum ExampleMarkdown {
    static let showcase = #"""
    # Markdown Showcase

    MarkdownText and MarkdownView can render common prose, rich inline styles, block content, math, tables, images, HTML, and custom renderer attachments.

    > A blockquote with **bold**, *italic*, a [link](https://swift.org), and `inline code`.
    >
    > It also keeps nested blocks together:
    > - Quote item one
    > - Quote item two with $a^2 + b^2 = c^2$

    ## Math

    Inline math: $x^2 + y^2 = c^2$.

    Display math:

    \[
    \int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
    \]

    Another display equation:

    $$
    \nabla \cdot \vec{E} = \frac{\rho}{\varepsilon_0}
    $$

    ## Text Formatting

    This paragraph contains:

    - **Bold**
    - *Italic*
    - ***Bold Italic***
    - ~~Strikethrough~~
    - `Inline code`
    - <kbd>Command-K</kbd>
    - Escaped punctuation: \*literal asterisks\*, \[literal brackets\], and \`literal backticks\`

    A link to [Apple](https://apple.com).

    https://swift.org

    Relative link resolved with the preview base URL: [MarkdownView documentation](/documentation/markdownview).

    Email autolink: <hello@example.com>

    ---

    ## Lists

    ### Unordered List

    - First item
    - Second item
      - Nested item
        - Deeply nested item

    ### Ordered List

    1. First
    2. Second
       1. Nested
       2. Nested
    3. Third

    ### Task List

    - [x] Completed task
    - [ ] Pending task
    - [ ] Parent task
      - [x] Nested completed task
      - [ ] Nested pending task

    ---

    ## Code

    ```swift
    import SwiftUI

    struct ContentView: View {
        var body: some View {
            Text("Hello, Markdown!")
        }
    }
    ```

    ```json
    {
      "name": "MarkdownView",
      "version": 1
    }
    ```

    ```bash
    swift test --filter MarkdownTextConverterTests
    ```

    ```diff
    - let renderer = DefaultRenderer()
    + let renderer = PreviewCalloutRenderer()
    ```

    ---

    ## Tables

    | Name | Language | Platform | Notes |
    |:-----|:--------:|---------:|------|
    | Swift | Native | Apple | Type-safe UI |
    | Rust | Systems | Cross-platform | Memory safety |
    | Markdown | Markup | Everywhere | Portable prose |

    ---

    ## Images

    ![Swift Logo](/assets/elements/icons/swift/swift-64x64_2x.png)

    ![Custom symbol image](symbol://sparkles)

    ---

    ## HTML

    <details>
    <summary>Expandable Section</summary>

    This content is inside a details block.
    </details>

    Inline HTML also works in prose, such as <mark>highlighted text</mark>.

    ---

    ## Custom Renderers

    The preview registers a custom link renderer for the `sample` URL scheme:

    [Open dashboard](sample://dashboard/active-users?range=7d)

    It also registers custom block directive and image renderers:

    @callout(type: "tip") {
    MarkdownText and MarkdownView can embed a custom SwiftUI view from a block directive.

    - Arguments are available to the renderer.
    - The wrapped markdown remains visible as preview content.
    }

    @callout(type: "warning") {
    Renderer registrations can customize one URL scheme or directive name while preserving the default rendering for the rest of the document.
    }

    ---

    ## Footnotes

    Here is a statement with a footnote.[^1]

    [^1]: This is the footnote content.

    ---

    ## Nested Structures

    > Quote level 1
    >
    > > Quote level 2
    > >
    > > - Nested list
    > > - Another item

    1. Ordered parent
       - Mixed unordered child
         1. Deep ordered item
         2. Another deep ordered item

    ---

    ## Line Breaks

    Soft line break
    continues in the same paragraph.

    Hard line break\
    starts a new rendered line.

    ---

    ## Emoji

    😀 🚀 ✨

    """#
}
