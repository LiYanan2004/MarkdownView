//
//  CustomCTFontConvertible.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/15.
//

import SwiftUI
import CoreText

/// A value that provides a custom `CTFont` representation.
public protocol CustomCTFontConvertible: Sendable {
    /// A `CTFont` representation of this type.
    var ctFont: CTFont { get }
}

extension CustomCTFontConvertible {
    /// The platform font representation of this type.
    public var asPlatformFont: PlatformFont {
        ctFont as PlatformFont
    }
}

extension PlatformFont: CustomCTFontConvertible {
    public var ctFont: CTFont {
        self as CTFont
    }
}

extension CTFont: CustomCTFontConvertible {
    public var ctFont: CTFont { self }
}

extension SwiftUI.Font: CustomCTFontConvertible {
    public var ctFont: CTFont {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *) {
            return resolve(in: EnvironmentValues().fontResolutionContext).ctFont
        } else {
            return PlatformFont.preferredFont(forTextStyle: .body).ctFont
        }
    }
}
