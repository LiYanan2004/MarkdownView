//
//  Either.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/22.
//

import Foundation

enum Either<T, U> {
    public typealias LeftValue = T
    public typealias RightValue = U
    
    case left(LeftValue)
    case right(RightValue)
}

extension Either where LeftValue == RightValue {
    var value: T {
        switch self {
        case .left(let leftValue):
            return leftValue
        case .right(let rightValue):
            return rightValue
        }
    }
}

extension Either where LeftValue: Collection, RightValue: Collection {
    var count: Int {
        switch self {
        case .left(let leftValue):
            leftValue.count
        case .right(let rightValue):
            rightValue.count
        }
    }
}

// MARK: - Conformances

extension Either: CustomDebugStringConvertible, CustomStringConvertible {
    public var description: String {
        switch self {
        case .left(let leftValue):
            String(describing: leftValue)
        case .right(let rightValue):
            String(describing: rightValue)
        }
    }
    
    public var debugDescription: String {
        switch self {
        case .left(let leftValue):
            "Either.left(\(String(describing: leftValue)))"
        case .right(let rightValue):
            "Either.right(\(String(describing: rightValue)))"
        }
    }
}

extension Either: Equatable where LeftValue: Equatable, RightValue: Equatable {
    static func == (lhs: Either, rhs: Either) -> Bool {
        switch (lhs, rhs) {
        case (.left(let x), .left(let y)):
            return x == y
        case (.right(let x), .right(let y)):
            return x == y
        default:
            return false
        }
    }
}

extension Either: Comparable where LeftValue: Comparable, RightValue: Comparable {
    
}

extension Either: Sendable where LeftValue: Sendable, RightValue: Sendable {
    
}

extension Either: Hashable where LeftValue: Hashable, RightValue: Hashable {
    
}
