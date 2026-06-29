import Foundation

enum Either<LeftValue, RightValue> {
    case left(LeftValue)
    case right(RightValue)
}

extension Either where LeftValue == RightValue {
    var value: LeftValue {
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

extension Either: CustomDebugStringConvertible, CustomStringConvertible {
    var description: String {
        switch self {
            case .left(let leftValue):
                String(describing: leftValue)
            case .right(let rightValue):
                String(describing: rightValue)
        }
    }
    
    var debugDescription: String {
        switch self {
            case .left(let leftValue):
                "Either.left(\(String(describing: leftValue)))"
            case .right(let rightValue):
                "Either.right(\(String(describing: rightValue)))"
        }
    }
}

extension Either: Equatable where LeftValue: Equatable, RightValue: Equatable { }
extension Either: Comparable where LeftValue: Comparable, RightValue: Comparable { }
extension Either: Sendable where LeftValue: Sendable, RightValue: Sendable { }
extension Either: Hashable where LeftValue: Hashable, RightValue: Hashable { }
