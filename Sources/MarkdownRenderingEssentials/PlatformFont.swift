//
//  PlatformFont.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/15.
//

#if canImport(UIKit)

import UIKit
public typealias PlatformFont = UIFont

#elseif canImport(AppKit)

import AppKit
public typealias PlatformFont = NSFont

#endif
