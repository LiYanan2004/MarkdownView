//
//  ASTDiffer.swift
//  MarkdownView
//
//  Created for streaming markdown rendering optimization
//

import Markdown
import Foundation

/// Represents the type of change detected in an AST comparison
enum ASTChangeType {
    case unchanged
    case modified
    case inserted
    case removed
}

/// Represents a change in the AST between two document parses
struct ASTChange {
    let type: ASTChangeType
    let oldIndex: Int?
    let newIndex: Int?
    let oldNode: (any BlockMarkup)?
    let newNode: (any BlockMarkup)?
}

/// Efficiently compares two markdown ASTs to identify changes for incremental rendering
struct ASTDiffer {
    /// Compare two documents and return a list of changes at the block level
    /// Uses content-based hashing for O(n) performance instead of O(n²)
    static func diff(
        old oldDocument: Document?,
        new newDocument: Document
    ) -> [ASTChange] {
        guard let oldDocument = oldDocument else {
            // First render - all nodes are insertions
            return Array(newDocument.children).enumerated().map { index, node in
                ASTChange(
                    type: .inserted,
                    oldIndex: nil,
                    newIndex: index,
                    oldNode: nil,
                    newNode: node as? (any BlockMarkup)
                )
            }
        }

        let oldBlocks = Array(oldDocument.children)
        let newBlocks = Array(newDocument.children)

        // Build hash map for O(1) lookups
        var oldHashMap: [Int: (index: Int, node: any BlockMarkup)] = [:]
        for (index, block) in oldBlocks.enumerated() {
            if let blockMarkup = block as? any BlockMarkup {
                oldHashMap[block.stableContentHash] = (index, blockMarkup)
            }
        }

        var changes: [ASTChange] = []
        var processedOldIndices: Set<Int> = []

        // First pass: identify unchanged, modified, and inserted nodes
        for (newIndex, newBlock) in newBlocks.enumerated() {
            guard let newBlockMarkup = newBlock as? any BlockMarkup else { continue }
            let hash = newBlock.stableContentHash

            if let (oldIndex, oldBlock) = oldHashMap[hash] {
                // Hash match - likely unchanged
                // Verify with structural comparison for certainty
                if oldBlock.hasSameStructure(as: newBlock) {
                    changes.append(ASTChange(
                        type: .unchanged,
                        oldIndex: oldIndex,
                        newIndex: newIndex,
                        oldNode: oldBlock,
                        newNode: newBlockMarkup
                    ))
                    processedOldIndices.insert(oldIndex)
                } else {
                    // Hash collision or content changed
                    changes.append(ASTChange(
                        type: .modified,
                        oldIndex: oldIndex,
                        newIndex: newIndex,
                        oldNode: oldBlock,
                        newNode: newBlockMarkup
                    ))
                    processedOldIndices.insert(oldIndex)
                }
            } else {
                // No hash match - this is a new node
                changes.append(ASTChange(
                    type: .inserted,
                    oldIndex: nil,
                    newIndex: newIndex,
                    oldNode: nil,
                    newNode: newBlockMarkup
                ))
            }
        }

        // Second pass: identify removed nodes
        for (oldIndex, oldBlock) in oldBlocks.enumerated() {
            guard let oldBlockMarkup = oldBlock as? any BlockMarkup else { continue }
            if !processedOldIndices.contains(oldIndex) {
                changes.append(ASTChange(
                    type: .removed,
                    oldIndex: oldIndex,
                    newIndex: nil,
                    oldNode: oldBlockMarkup,
                    newNode: nil
                ))
            }
        }

        return changes.sorted { lhs, rhs in
            // Sort by new index for rendering order, removed items go to end
            let lhsIndex = lhs.newIndex ?? Int.max
            let rhsIndex = rhs.newIndex ?? Int.max
            return lhsIndex < rhsIndex
        }
    }

    /// Fast check if documents are identical at block level
    static func areIdentical(old: Document?, new: Document) -> Bool {
        guard let old = old else { return false }

        let oldBlocks = Array(old.children)
        let newBlocks = Array(new.children)

        guard oldBlocks.count == newBlocks.count else { return false }

        for (oldBlock, newBlock) in zip(oldBlocks, newBlocks) {
            if !oldBlock.hasSameContentHash(as: newBlock) {
                return false
            }
        }

        return true
    }

    /// Calculate cache hit rate for statistics/debugging
    static func calculateCacheHitRate(changes: [ASTChange]) -> Double {
        let unchangedCount = changes.filter { $0.type == .unchanged }.count
        let totalCount = changes.count

        guard totalCount > 0 else { return 0.0 }
        return Double(unchangedCount) / Double(totalCount)
    }
}

// MARK: - Debug Helpers

extension ASTChange: CustomStringConvertible {
    var description: String {
        switch type {
        case .unchanged:
            return "Unchanged[\(newIndex!)]"
        case .modified:
            return "Modified[\(oldIndex!) → \(newIndex!)]"
        case .inserted:
            return "Inserted[\(newIndex!)]"
        case .removed:
            return "Removed[\(oldIndex!)]"
        }
    }
}
