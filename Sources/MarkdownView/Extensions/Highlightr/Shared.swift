//
//  Shared.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

#if canImport(Highlightr)
@preconcurrency import Highlightr
#endif

#if canImport(Highlightr)
extension Highlightr {
    static let shared: ActorIsolated<Highlightr?> = ActorIsolated(Highlightr())
}
#endif
