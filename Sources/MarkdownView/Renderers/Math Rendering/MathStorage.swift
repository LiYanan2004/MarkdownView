//
//  MathStorage.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/13.
//

import Foundation

@MainActor
class MathStorage: @unchecked Sendable {
    static private(set) var lookupTable: [UUID : String] = [:]
    
    static func appendMathExpression(_ exp: some StringProtocol) -> UUID {
        if let id = lookupTable.values.firstIndex(of: String(exp)) {
            return lookupTable[id].key
        }
        
        let uuid = UUID()
        lookupTable[uuid] = String(exp)
        return uuid
    }
}
