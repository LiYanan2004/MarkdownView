//
//  ContentHashingTests.swift
//  MarkdownView
//
//  Tests for content-based hashing used for stable view identity
//

import Testing
@preconcurrency import Markdown
@testable import MarkdownView

@MainActor
struct ContentHashingTests {

    // MARK: - Hash Stability Tests

    @Test("Identical content produces identical hashes")
    func testIdenticalContentHash() {
        let text1 = "# Hello World\n\nThis is a paragraph."
        let text2 = "# Hello World\n\nThis is a paragraph."

        let doc1 = Document(parsing: text1)
        let doc2 = Document(parsing: text2)

        // Documents with identical content should have identical hashes
        for (child1, child2) in zip(doc1.children, doc2.children) {
            #expect(child1.stableContentHash == child2.stableContentHash)
        }
    }

    @Test("Different content produces different hashes")
    func testDifferentContentHash() {
        let text1 = "# Hello World"
        let text2 = "# Goodbye World"

        let doc1 = Document(parsing: text1)
        let doc2 = Document(parsing: text2)

        let hash1 = Array(doc1.children).first?.stableContentHash
        let hash2 = Array(doc2.children).first?.stableContentHash

        #expect(hash1 != hash2)
    }

    @Test("Hash changes when content changes")
    func testHashChangesWithContent() {
        let originalText = "This is a paragraph."
        let modifiedText = "This is a modified paragraph."

        let doc1 = Document(parsing: originalText)
        let doc2 = Document(parsing: modifiedText)

        let hash1 = Array(doc1.children).first?.stableContentHash
        let hash2 = Array(doc2.children).first?.stableContentHash

        #expect(hash1 != hash2)
    }

    // MARK: - Node Type Hashing

    @Test("Different node types have different hashes")
    func testDifferentNodeTypesHash() {
        let markdown = """
        # Heading

        Paragraph

        - List item

        ```swift
        code
        ```
        """

        let doc = Document(parsing: markdown)
        let children = Array(doc.children)

        // All different node types should have different hashes
        let hashes = children.map { $0.stableContentHash }
        let uniqueHashes = Set(hashes)

        #expect(hashes.count == uniqueHashes.count)
    }

    @Test("Same node type with different attributes")
    func testSameTypeWithDifferentAttributes() {
        let markdown = """
        # Heading 1

        ## Heading 2

        ### Heading 3
        """

        let doc = Document(parsing: markdown)
        let headings = doc.children.compactMap { $0 as? Heading }

        #expect(headings.count == 3)

        // Different heading levels should have different hashes
        let h1Hash = headings[0].stableContentHash
        let h2Hash = headings[1].stableContentHash
        let h3Hash = headings[2].stableContentHash

        #expect(h1Hash != h2Hash)
        #expect(h2Hash != h3Hash)
        #expect(h1Hash != h3Hash)
    }

    // MARK: - Structural Hashing

    @Test("Child count affects hash")
    func testChildCountAffectsHash() {
        let markdown1 = "- Item 1"
        let markdown2 = "- Item 1\n- Item 2"

        let doc1 = Document(parsing: markdown1)
        let doc2 = Document(parsing: markdown2)

        let list1 = Array(doc1.children).first as? UnorderedList
        let list2 = Array(doc2.children).first as? UnorderedList

        #expect(list1 != nil)
        #expect(list2 != nil)

        #expect(list1?.stableContentHash != list2?.stableContentHash)
    }

    @Test("Nested structure affects hash")
    func testNestedStructureHash() {
        let markdown1 = "> Quote"
        let markdown2 = "> > Nested quote"

        let doc1 = Document(parsing: markdown1)
        let doc2 = Document(parsing: markdown2)

        let hash1 = Array(doc1.children).first?.stableContentHash
        let hash2 = Array(doc2.children).first?.stableContentHash

        #expect(hash1 != hash2)
    }

    // MARK: - Code Block Hashing

    @Test("Code blocks with different languages")
    func testCodeBlockLanguageHash() {
        let markdown1 = "```swift\nlet x = 1\n```"
        let markdown2 = "```python\nlet x = 1\n```"

        let doc1 = Document(parsing: markdown1)
        let doc2 = Document(parsing: markdown2)

        let code1 = Array(doc1.children).first as? CodeBlock
        let code2 = Array(doc2.children).first as? CodeBlock

        #expect(code1?.stableContentHash != code2?.stableContentHash)
    }

    @Test("Code blocks with same language but different content")
    func testCodeBlockContentHash() {
        let markdown1 = "```swift\nlet x = 1\n```"
        let markdown2 = "```swift\nlet y = 2\n```"

        let doc1 = Document(parsing: markdown1)
        let doc2 = Document(parsing: markdown2)

        let hash1 = Array(doc1.children).first?.stableContentHash
        let hash2 = Array(doc2.children).first?.stableContentHash

        #expect(hash1 != hash2)
    }

    // MARK: - Link and Image Hashing

    @Test("Links with different destinations")
    func testLinkDestinationHash() {
        let markdown1 = "[Link](https://example.com)"
        let markdown2 = "[Link](https://other.com)"

        let doc1 = Document(parsing: markdown1)
        let doc2 = Document(parsing: markdown2)

        // Get the paragraph containing the link
        let para1 = Array(doc1.children).first
        let para2 = Array(doc2.children).first

        #expect(para1?.stableContentHash != para2?.stableContentHash)
    }

    @Test("Images with different sources")
    func testImageSourceHash() {
        let markdown1 = "![Alt](image1.png)"
        let markdown2 = "![Alt](image2.png)"

        let doc1 = Document(parsing: markdown1)
        let doc2 = Document(parsing: markdown2)

        let para1 = Array(doc1.children).first
        let para2 = Array(doc2.children).first

        #expect(para1?.stableContentHash != para2?.stableContentHash)
    }

    // MARK: - hasSameContentHash Helper

    @Test("hasSameContentHash returns true for identical nodes")
    func testHasSameContentHashTrue() {
        let text = "This is a test paragraph."
        let doc1 = Document(parsing: text)
        let doc2 = Document(parsing: text)

        guard let node1 = Array(doc1.children).first,
              let node2 = Array(doc2.children).first else {
            Issue.record("Failed to get children")
            return
        }

        #expect(node1.hasSameContentHash(as: node2))
    }

    @Test("hasSameContentHash returns false for different nodes")
    func testHasSameContentHashFalse() {
        let doc1 = Document(parsing: "Paragraph 1")
        let doc2 = Document(parsing: "Paragraph 2")

        guard let node1 = Array(doc1.children).first,
              let node2 = Array(doc2.children).first else {
            Issue.record("Failed to get children")
            return
        }

        #expect(!node1.hasSameContentHash(as: node2))
    }

    // MARK: - Performance Characteristics

    @Test("Hash calculation is reasonably fast")
    func testHashPerformance() async {
        let largeMarkdown = """
        # Large Document

        \(String(repeating: "This is paragraph number.\n\n", count: 100))
        """

        let doc = Document(parsing: largeMarkdown)

        let startTime = ContinuousClock.now

        // Calculate hashes for all children
        for child in doc.children {
            _ = child.stableContentHash
        }

        let elapsed = startTime.duration(to: ContinuousClock.now)

        // Should be fast - less than 100ms for 100 nodes
        #expect(elapsed < .milliseconds(100))
    }

    // MARK: - Edge Cases

    @Test("Empty document children")
    func testEmptyDocumentHash() {
        let doc = Document(parsing: "")
        let children = Array(doc.children)

        // Empty documents should still be hashable
        #expect(children.isEmpty)
    }

    @Test("Very long text content (truncation)")
    func testVeryLongTextHash() {
        // Hash should handle very long content (it truncates to 100 chars)
        let longText = String(repeating: "A", count: 10000)
        let doc1 = Document(parsing: longText)
        let doc2 = Document(parsing: longText)

        let hash1 = Array(doc1.children).first?.stableContentHash
        let hash2 = Array(doc2.children).first?.stableContentHash

        #expect(hash1 == hash2)
    }

    @Test("Text vs InlineCode vs CodeBlock hashing")
    func testTextContentTypeHashing() {
        let markdown = """
        Normal text

        `inline code`

        ```
        code block
        ```
        """

        let doc = Document(parsing: markdown)
        let children = Array(doc.children)

        // Should have 3 different paragraphs/blocks
        #expect(children.count == 3)

        // All should have different hashes due to different content types
        let hashes = children.map { $0.stableContentHash }
        let uniqueHashes = Set(hashes)
        #expect(hashes.count == uniqueHashes.count)
    }
}
