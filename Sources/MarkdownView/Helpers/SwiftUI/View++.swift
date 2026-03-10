//
//  View++.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/2/25.
//

import SwiftUI

// MARK: - AnyView

extension View {
    @_spi(Internal)
    nonisolated public func erasedToAnyView() -> AnyView {
        AnyView(self)
    }
}

// MARK: - Content Padding

extension View {
    @_spi(Internal)
    @ViewBuilder
    nonisolated public func contentPadding(
        _ edges: Edge.Set = .all,
        _ length: CGFloat? = nil
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            safeAreaPadding(edges, length)
        } else {
            safeAreaInset(edge: .top, spacing: 0) {
                EmptyView()
                    .frame(width: 0, height: 0)
                    .padding(.top, edges.contains(.top) ? length : 0)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                EmptyView()
                    .frame(width: 0, height: 0)
                    .padding(.bottom, edges.contains(.bottom) ? length : 0)
            }
            .safeAreaInset(edge: .leading, spacing: 0) {
                EmptyView()
                    .frame(width: 0, height: 0)
                    .padding(.leading, edges.contains(.leading) ? length : 0)
            }
            .safeAreaInset(edge: .trailing, spacing: 0) {
                EmptyView()
                    .frame(width: 0, height: 0)
                    .padding(.trailing, edges.contains(.trailing) ? length : 0)
            }
        }
    }
    
    @_spi(Internal)
    nonisolated public func contentPadding(
        _ length: CGFloat
    ) -> some View {
        contentPadding(.all, length)
    }
}
