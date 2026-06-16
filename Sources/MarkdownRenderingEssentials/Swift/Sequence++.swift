import Foundation

extension Sequence {
    @_spi(Internal)
    public func first<Value>(
        byUnwrapping transform: (Element) throws -> Value?
    ) rethrows -> Value? {
        try lazy.compactMap(transform).first
    }
}
