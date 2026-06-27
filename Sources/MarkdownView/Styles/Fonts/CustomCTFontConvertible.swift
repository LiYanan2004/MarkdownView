//
//  CustomCTFontConvertible.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/15.
//

import SwiftUI
import CoreText
import OSLog

/// A value that provides a custom `CTFont` representation.
public protocol CustomCTFontConvertible: Sendable {
    /// A `CTFont` representation of this type.
    var ctFont: CTFont { get }
    
    var _swiftUIFont: Font { get }
}

extension CustomCTFontConvertible {
    /// The platform font representation of this type.
    public var asPlatformFont: PlatformFont {
        ctFont as PlatformFont
    }
    
    public var _swiftUIFont: Font {
        Font(asPlatformFont)
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
    public var _swiftUIFont: Font {
        self
    }
    
    public var ctFont: CTFont {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *) {
            return resolve(in: EnvironmentValues().fontResolutionContext).ctFont
        } else {
            Logger.runtime.warning("`SwiftUI.Font` can't be resolved as Platform font (requires OS 26 or later). Use preferred body font instead.")
            return PlatformFont.preferredFont(forTextStyle: .body).ctFont
        }
    }
}
