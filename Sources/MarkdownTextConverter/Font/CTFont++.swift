//
//  CTFont++.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/15.
//

import CoreText

extension CTFont {
    func monospaced(_ isMonospaced: Bool = true) -> CTFont {
        guard isMonospaced else {
            return self
        }

        return CTFontCreateCopyWithSymbolicTraits(
            self,
            CTFontGetSize(self),
            nil,
            .traitMonoSpace,
            .traitMonoSpace
        ) ?? self
    }
}
