//
//  ASTDifferTests.swift
//  MarkdownView
//
//  Tests for AST diffing algorithm used for incremental rendering
//

import Testing
@preconcurrency import Markdown
@testable import MarkdownView

@MainActor
struct ASTDifferTests {

    // MARK: - Basic Diff Detection

    @Test("Detect all unchanged nodes")
    func testAllUnchanged() {
        let markdown = """
        # Heading

        Paragraph 1

        Paragraph 2
        """

        let doc1 = Document(parsing: markdown)
        let doc2 = Document(parsing: markdown)

        let changes = ASTDiffer.diff(old: doc1, new: doc2)

        // All nodes should be unchanged
        #expect(changes.allSatisfy { $0.type == .unchanged })
        #expect(changes.count == 3) // heading + 2 paragraphs
    }

    @Test("Detect inserted node at end")
    func testInsertedAtEnd() {
        let markdown1 = """
        # Heading

        Paragraph 1
        """

        let markdown2 = """
        # Heading

        Paragraph 1

        Paragraph 2
        """

        let doc1 = Document(parsing: markdown1)
        let doc2 = Document(parsing: markdown2)

        let changes = ASTDiffer.diff(old: doc1, new: doc2)

        let unchanged = changes.filter { $0.type == .unchanged }
        let inserted = changes.filter { $0.type == .inserted }

        #expect(unchanged.count == 2) // heading + paragraph 1
        #expect(inserted.count == 1) // paragraph 2
        #expect(inserted.first?.newIndex == 2)
    }

    @Test("Detect inserted node at beginning")
    func testInsertedAtBeginning() {
        let markdown1 = """
        Paragraph 1
        """

        let markdown2 = """
        # New Heading

        Paragraph 1
        """

        let doc1 = Document(parsing: markdown1)
        let doc2 = Document(parsing: markdown2)

        let changes = ASTDiffer.diff(old: doc1, new: doc2)

        let unchanged = changes.filter { $0.type == .unchanged }
        let inserted = changes.filter { $0.type == .inserted }

        #expect(unchanged.count == 1) // paragraph 1
        #expect(inserted.count == 1) // heading
        #expect(inserted.first?.newIndex == 0)
    }

    @Test("Detect removed node")
    func testRemovedNode() {
        let markdown1 = """
        # Heading

        Paragraph 1

        Paragraph 2
        """

        let markdown2 = """
        # Heading

        Paragraph 2
        """

        let doc1 = Document(parsing: markdown1)
        let doc2 = Document(parsing: markdown2)

        let changes = ASTDiffer.diff(old: doc1, new: doc2)

        let removed = changes.filter { $0.type == .removed }

        #expect(removed.count == 1)
        #expect(removed.first?.oldIndex == 1) // Paragraph 1 was at index 1
    }

    @Test("Detect modified node")
    func testModifiedNode() {
        let markdown1 = """
        # Original Heading
        """

        let markdown2 = """
        # Modified Heading
        """

        let doc1 = Document(parsing: markdown1)
        let doc2 = Document(parsing: markdown2)

        let changes = ASTDiffer.diff(old: doc1, new: doc2)

        // Hash-based diffing reports content changes as removed + inserted
        #expect(changes.count == 2)
        let hasRemoved = changes.contains { $0.type == .removed }
        let hasInserted = changes.contains { $0.type == .inserted }
        #expect(hasRemoved)
        #expect(hasInserted)
    }

    // MARK: - First Render (Nil Old Document)

    @Test("First render - all nodes inserted")
    func testFirstRender() {
        let markdown = """
        # Heading

        Paragraph 1

        Paragraph 2
        """

        let doc = Document(parsing: markdown)
        let changes = ASTDiffer.diff(old: nil, new: doc)

        // All nodes should be marked as inserted
        #expect(changes.allSatisfy { $0.type == .inserted })
        #expect(changes.count == 3)

        // Verify indices
        for (index, change) in changes.enumerated() {
            #expect(change.newIndex == index)
            #expect(change.oldIndex == nil)
        }
    }

    // MARK: - Complex Scenarios

    @Test("Multiple changes simultaneously")
    func testMultipleChanges() {
        let markdown1 = """
        # Heading 1

        Paragraph 1

        Paragraph 2
        """

        let markdown2 = """
        # Heading 1

        Paragraph 1 - Modified

        Paragraph 3

        Paragraph 4
        """

        let doc1 = Document(parsing: markdown1)
        let doc2 = Document(parsing: markdown2)

        let changes = ASTDiffer.diff(old: doc1, new: doc2)

        let unchanged = changes.filter { $0.type == .unchanged }
        let modified = changes.filter { $0.type == .modified }
        let inserted = changes.filter { $0.type == .inserted }
        let removed = changes.filter { $0.type == .removed }

        // Heading should be unchanged
        #expect(unchanged.count >= 1)

        // Should have some combination of modifications and insertions
        #expect(modified.count + inserted.count + removed.count > 0)
    }

    @Test("Reordered nodes")
    func testReorderedNodes() {
        let markdown1 = """
        Paragraph A

        Paragraph B
        """

        let markdown2 = """
        Paragraph B

        Paragraph A
        """

        let doc1 = Document(parsing: markdown1)
        let doc2 = Document(parsing: markdown2)

        let changes = ASTDiffer.diff(old: doc1, new: doc2)

        // Reordering should be detected as changes (not as unchanged)
        // The diffing algorithm doesn't track reordering, so these will show as
        // different nodes at different indices
        #expect(changes.count == 2)
    }

    // MARK: - Cache Hit Rate Calculation

    @Test("Calculate cache hit rate - all unchanged")
    func testCacheHitRateAllUnchanged() {
        let markdown = "# Heading\n\nParagraph"
        let doc1 = Document(parsing: markdown)
        let doc2 = Document(parsing: markdown)

        let changes = ASTDiffer.diff(old: doc1, new: doc2)
        let hitRate = ASTDiffer.calculateCacheHitRate(changes: changes)

        #expect(hitRate == 1.0) // 100% unchanged
    }

    @Test("Calculate cache hit rate - none unchanged")
    func testCacheHitRateNoneUnchanged() {
        let doc = Document(parsing: "# Heading")
        let changes = ASTDiffer.diff(old: nil, new: doc)
        let hitRate = ASTDiffer.calculateCacheHitRate(changes: changes)

        #expect(hitRate == 0.0) // 0% unchanged (all inserted)
    }

    @Test("Calculate cache hit rate - partial")
    func testCacheHitRatePartial() {
        let markdown1 = """
        # Unchanged

        Old paragraph
        """

        let markdown2 = """
        # Unchanged

        New paragraph
        """

        let doc1 = Document(parsing: markdown1)
        let doc2 = Document(parsing: markdown2)

        let changes = ASTDiffer.diff(old: doc1, new: doc2)
        let hitRate = ASTDiffer.calculateCacheHitRate(changes: changes)

        // Should be around 50% (1 of 2 unchanged)
        #expect(hitRate > 0.0)
        #expect(hitRate < 1.0)
    }

    @Test("Calculate cache hit rate - empty")
    func testCacheHitRateEmpty() {
        let changes: [ASTChange] = []
        let hitRate = ASTDiffer.calculateCacheHitRate(changes: changes)

        #expect(hitRate == 0.0) // No nodes = 0% hit rate
    }

    // MARK: - areIdentical Helper

    @Test("areIdentical returns true for same content")
    func testAreIdenticalTrue() {
        let markdown = "# Heading\n\nParagraph"
        let doc1 = Document(parsing: markdown)
        let doc2 = Document(parsing: markdown)

        #expect(ASTDiffer.areIdentical(old: doc1, new: doc2))
    }

    @Test("areIdentical returns false for different content")
    func testAreIdenticalFalse() {
        let doc1 = Document(parsing: "# Heading 1")
        let doc2 = Document(parsing: "# Heading 2")

        #expect(!ASTDiffer.areIdentical(old: doc1, new: doc2))
    }

    @Test("areIdentical returns false for nil old document")
    func testAreIdenticalNilOld() {
        let doc = Document(parsing: "# Heading")

        #expect(!ASTDiffer.areIdentical(old: nil, new: doc))
    }

    @Test("areIdentical returns false for different lengths")
    func testAreIdenticalDifferentLengths() {
        let doc1 = Document(parsing: "Paragraph 1")
        let doc2 = Document(parsing: "Paragraph 1\n\nParagraph 2")

        #expect(!ASTDiffer.areIdentical(old: doc1, new: doc2))
    }

    // MARK: - Streaming Scenario Tests

    @Test("Typical streaming append")
    func testTypicalStreamingAppend() {
        // Simulate LLM streaming where new content is appended
        let chunk1 = "# Heading\n\nParagraph 1"
        let chunk2 = "# Heading\n\nParagraph 1\n\nParagraph 2"
        let chunk3 = "# Heading\n\nParagraph 1\n\nParagraph 2\n\nParagraph 3"

        let doc1 = Document(parsing: chunk1)
        let doc2 = Document(parsing: chunk2)
        let doc3 = Document(parsing: chunk3)

        // First update: chunk1 → chunk2
        let changes1to2 = ASTDiffer.diff(old: doc1, new: doc2)
        let hitRate1to2 = ASTDiffer.calculateCacheHitRate(changes: changes1to2)

        // Should have high hit rate (heading + paragraph 1 unchanged)
        #expect(hitRate1to2 >= 0.6) // At least 60% hit rate

        // Second update: chunk2 → chunk3
        let changes2to3 = ASTDiffer.diff(old: doc2, new: doc3)
        let hitRate2to3 = ASTDiffer.calculateCacheHitRate(changes: changes2to3)

        // Should also have high hit rate
        #expect(hitRate2to3 >= 0.6)
    }

    @Test("Streaming with paragraph completion")
    func testStreamingParagraphCompletion() {
        // Incomplete paragraph vs complete
        let incomplete = "This is an incomplete para"
        let complete = "This is an incomplete paragraph."

        let doc1 = Document(parsing: incomplete)
        let doc2 = Document(parsing: complete)

        let changes = ASTDiffer.diff(old: doc1, new: doc2)

        // Hash-based diffing reports content changes as removed + inserted
        #expect(changes.count == 2)
        let changesNotUnchanged = changes.filter { $0.type != .unchanged }
        #expect(changesNotUnchanged.count == 2)
    }

    @Test("Large document with small change")
    func testLargeDocumentSmallChange() {
        // Create large document with many paragraphs
        var paragraphs: [String] = []
        for i in 1...50 {
            paragraphs.append("Paragraph \(i)")
        }

        let markdown1 = paragraphs.joined(separator: "\n\n")
        let markdown2 = markdown1 + "\n\nNew paragraph"

        let doc1 = Document(parsing: markdown1)
        let doc2 = Document(parsing: markdown2)

        let changes = ASTDiffer.diff(old: doc1, new: doc2)
        let hitRate = ASTDiffer.calculateCacheHitRate(changes: changes)

        // Should have very high hit rate (50 of 51 unchanged)
        #expect(hitRate >= 0.95) // At least 95% hit rate

        let unchanged = changes.filter { $0.type == .unchanged }
        #expect(unchanged.count == 50)
    }

    // MARK: - Edge Cases

    @Test("Empty documents")
    func testEmptyDocuments() {
        let doc1 = Document(parsing: "")
        let doc2 = Document(parsing: "")

        let changes = ASTDiffer.diff(old: doc1, new: doc2)

        #expect(changes.isEmpty)
    }

    @Test("Whitespace-only changes")
    func testWhitespaceChanges() {
        let doc1 = Document(parsing: "Paragraph 1")
        let doc2 = Document(parsing: "Paragraph 1\n\n\n") // Extra whitespace

        let changes = ASTDiffer.diff(old: doc1, new: doc2)

        // Should detect as unchanged (trailing whitespace doesn't create new nodes)
        #expect(changes.count == 1)
        #expect(changes.first?.type == .unchanged)
    }

    // MARK: - Change Metadata

    @Test("Change indices are correct")
    func testChangeIndices() {
        let markdown1 = "Para 1\n\nPara 2\n\nPara 3"
        let markdown2 = "Para 1\n\nModified\n\nPara 3"

        let doc1 = Document(parsing: markdown1)
        let doc2 = Document(parsing: markdown2)

        let changes = ASTDiffer.diff(old: doc1, new: doc2)

        // Para 1: unchanged at index 0
        let para1Change = changes.first { $0.oldIndex == 0 }
        #expect(para1Change?.type == .unchanged)
        #expect(para1Change?.newIndex == 0)

        // Para 2: modified at index 1
        let para2Change = changes.first { $0.oldIndex == 1 || $0.newIndex == 1 }
        #expect(para2Change != nil)

        // Para 3: unchanged, moved or new position
        let para3Changes = changes.filter { $0.oldIndex == 2 || $0.newIndex == 2 }
        #expect(!para3Changes.isEmpty)
    }

    @Test("Changes are sorted by new index")
    func testChangesSorted() {
        let markdown1 = "A\n\nB\n\nC"
        let markdown2 = "A\n\nB\n\nC\n\nD\n\nE"

        let doc1 = Document(parsing: markdown1)
        let doc2 = Document(parsing: markdown2)

        let changes = ASTDiffer.diff(old: doc1, new: doc2)

        // Verify sorted order
        var lastIndex = -1
        for change in changes.filter({ $0.newIndex != nil }) {
            let currentIndex = change.newIndex!
            #expect(currentIndex >= lastIndex)
            lastIndex = currentIndex
        }
    }
}
