#if canImport(RichText)

import RichText
import SwiftUI

extension TextContent {
    @MainActor
    func mergingAttributes(
        _ attributes: AttributeContainer,
        mergePolicy: AttributedString.AttributeMergePolicy = .keepNew
    ) -> TextContent {
        TextContent(
            fragments.map { fragment in
                switch fragment {
                case .string(let string):
                    .attributedString(AttributedString(string, attributes: attributes))
                case .attributedString(let attributedString):
                    .attributedString(attributedString.mergingAttributes(attributes, mergePolicy: mergePolicy))
                case .view:
                    .attributedString(fragment.asAttributedString().mergingAttributes(attributes, mergePolicy: mergePolicy))
                }
            }
        )
    }

    @MainActor
    func attributedString(options: AttributedStringOption = []) -> AttributedString {
        fragments.reduce(into: AttributedString()) { attributedString, fragment in
            switch fragment {
            case .string(let string):
                attributedString += AttributedString(string)
            case .attributedString(let value):
                attributedString += value
            case .view:
                if !options.contains(.ignoresEmbeddedView) {
                    attributedString += fragment.asAttributedString()
                }
            }
        }
    }

    struct AttributedStringOption: OptionSet {
        var rawValue: UInt8

        static let ignoresEmbeddedView = AttributedStringOption(rawValue: 1 << 0)
    }
}

#endif
