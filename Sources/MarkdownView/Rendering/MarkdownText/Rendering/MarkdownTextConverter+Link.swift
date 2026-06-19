#if canImport(RichText)

import Markdown
import RichText
import SwiftUI

extension MarkdownTextConverter {
    func linkReplacement(for link: Markdown.Link, url: URL) -> AttributedString? {
        let label = descendInto(link).attributedString(options: .ignoresEmbeddedView)
        guard !label.characters.isEmpty else {
            return nil
        }

        var attributes = AttributeContainer()
            .link(url)
            .foregroundColor(configuration.tintColors[.link] ?? .accentColor)
        attributes.underlineStyle = configuration.underlineLinks ? .single : .none

        return label.mergingAttributes(attributes)
    }

    func linkRenderer(for url: URL) -> (any MarkdownLinkRenderer)? {
        guard let scheme = url.scheme else {
            return nil
        }

        return elementRenderers
            .compactMap(\.link)
            .first(where: { $0.scheme == scheme })?
            .renderer
    }
}

#endif
