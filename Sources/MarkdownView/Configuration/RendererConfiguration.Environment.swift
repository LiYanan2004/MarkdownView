//
//  RendererConfiguration.Environment.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import Foundation
import SwiftUI

struct MarkdownRendererConfigurationKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: MarkdownView.RendererConfiguration = .init()
}

extension EnvironmentValues {
    var markdownRendererConfiguration: MarkdownView.RendererConfiguration {
        get { self[MarkdownRendererConfigurationKey.self] }
        set { self[MarkdownRendererConfigurationKey.self] = newValue }
    }
}
