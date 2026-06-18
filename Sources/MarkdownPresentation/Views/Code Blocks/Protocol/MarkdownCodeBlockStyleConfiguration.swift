/// The properties of a code block.
public struct MarkdownCodeBlockStyleConfiguration: Hashable, Sendable, Codable {
    public var language: String?
    public var code: String

    package init(language: String?, code: String) {
        self.language = language
        self.code = code
    }
}

@_documentation(visibility: internal)
@available(*, deprecated, renamed: "MarkdownCodeBlockStyleConfiguration")
public typealias CodeBlockStyleConfiguration = MarkdownCodeBlockStyleConfiguration
