import Markdown

extension SourceLocation {
    @available(*, deprecated, message: "Use `SourceLocation.offset(in:) -> String.Index` instead")
    public func offset(in text: String) -> Int {
        let colIndex = column - 1
        let previousLinesTotalCharacterCount = text
            .split(separator: "\n", maxSplits: line - 1, omittingEmptySubsequences: false)
            .dropLast()
            .map { String($0) }
            .joined(separator: "\n")
            .count
        return previousLinesTotalCharacterCount + colIndex + 1
    }

    public func offset(in text: String) -> String.Index {
        let colIndex = column - 1
        let previousLinesTotalCharacterCount = text
            .split(separator: "\n", maxSplits: line - 1, omittingEmptySubsequences: false)
            .dropLast()
            .joined(separator: "\n")
            .count
        return text.index(text.startIndex, offsetBy: previousLinesTotalCharacterCount + colIndex + 1)
    }
    
    static let start = SourceLocation(
        line: 1,
        column: 1,
        source: nil
    )
}
