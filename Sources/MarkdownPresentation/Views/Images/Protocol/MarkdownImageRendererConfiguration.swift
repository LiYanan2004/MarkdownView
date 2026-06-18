import Foundation

/// The properties of a markdown image.
public struct MarkdownImageRendererConfiguration: Sendable {
    /// The source url of an image.
    public var url: URL
    /// The alternative text of an image.
    public var alternativeText: String?
}
