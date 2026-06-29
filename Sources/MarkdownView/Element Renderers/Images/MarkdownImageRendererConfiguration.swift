import Foundation

/// The values that describe a markdown image.
public struct MarkdownImageRendererConfiguration: Sendable {
    /// The resolved source URL of the image.
    public var url: URL

    /// The alternative text from the image label, when one is present.
    public var alternativeText: String?
}
