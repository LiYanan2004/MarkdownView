//
//  CustomCTFontConvertible.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/15.
//

import SwiftUI
import CoreText
import MarkdownRenderingEssentials

public protocol CustomCTFontConvertible {
    var ctFont: CTFont { get }
}

extension CustomCTFontConvertible {
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
        if #available(iOS 26, macOS 26, *) {
            resolve(in: EnvironmentValues().fontResolutionContext).ctFont
        } else {
            preconditionFailure("Unsupported")
        }
    }
}
