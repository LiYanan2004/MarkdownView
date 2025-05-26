//
//  AnyShape.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/5/26.
//

import SwiftUI

/// A back-deployable version of `AnyShape` type eraser.
struct _AnyShape: Shape, Sendable {
    final class Storage: Sendable {
        let _underlyingShape: any Shape
        
        init(_underlyingShape: any Shape) {
            self._underlyingShape = _underlyingShape
        }
    }
    var storage: Storage
    private var _shape: any Shape { storage._underlyingShape }
    
    init<T: Shape>(_ shape: T) {
        self.storage = Storage(_underlyingShape: shape)
    }
    
    nonisolated func path(in rect: CGRect) -> Path {
        _shape.path(in: rect)
    }
    
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    nonisolated var layoutDirectionBehavior: LayoutDirectionBehavior {
        _shape.layoutDirectionBehavior
    }
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    nonisolated func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        _shape.sizeThatFits(proposal)
    }
}
