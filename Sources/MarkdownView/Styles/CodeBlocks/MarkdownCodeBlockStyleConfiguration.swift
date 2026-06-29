/// The properties of a code block.
public struct MarkdownCodeBlockStyleConfiguration: Hashable, Sendable, Codable {
    /// The language identifier from the code fence.
    public var language: String?

    /// The code block source.
    public var code: String

    init(language: String?, code: String) {
        self.language = language
        self.code = code
    }
}

@_documentation(visibility: internal)
@available(*, deprecated, renamed: "MarkdownCodeBlockStyleConfiguration")
public typealias CodeBlockStyleConfiguration = MarkdownCodeBlockStyleConfiguration
