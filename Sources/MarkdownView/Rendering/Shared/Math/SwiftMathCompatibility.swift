//
//  SwiftMathCompatibility.swift
//  MarkdownView
//

#if ENABLE_MATH_RENDERING

import Foundation
import SwiftMath

enum SwiftMathCompatibility {
    private static let aliases: [String: String] = KaTeXCompatibilityTable.macros.merging(
        [
            "dfrac": #"\frac"#, "tfrac": #"\frac"#, "cfrac": #"\frac"#,
            "dbinom": #"\binom"#, "tbinom": #"\binom"#,
            "boldsymbol": #"\mathbf"#, "bm": #"\mathbf"#, "pmb": #"\mathbf"#,
            "operatorname": #"\mathrm"#,
            "dots": #"\ldots"#, "dotsc": #"\ldots"#, "dotso": #"\ldots"#,
            "dotsb": #"\cdots"#, "dotsm": #"\cdots"#, "dotsi": #"\cdots"#,
            "lvert": "|", "rvert": "|", "lVert": #"\Vert"#, "rVert": #"\Vert"#,
            "implies": #"\;\Longrightarrow\;"#, "impliedby": #"\;\Longleftarrow\;"#,
            "bmod": #"\;\mathrm{mod}\;"#, "mod": #"\;\;\mathrm{mod}\;"#,
        ],
        uniquingKeysWith: { _, structural in structural }
    ).merging(
        ["big", "Big", "bigg", "Bigg"].flatMap { size in
            ["", "l", "r", "m"].map { (size + $0, "") }
        },
        uniquingKeysWith: { _, size in size }
    )

    // Only characters whose command SwiftMath can typeset (KaTeX reads ¶ as \P, which it lacks)
    static let unicode: [Character: String] = KaTeXCompatibilityTable.unicode.merging(
        [
            "≠": "neq", "∉": "notin",
            "ℕ": "mathbb{N}", "ℤ": "mathbb{Z}", "ℚ": "mathbb{Q}", "ℝ": "mathbb{R}", "ℂ": "mathbb{C}",
        ],
        uniquingKeysWith: { katex, _ in katex }
    ).filter { _, command in typesettable(command) }

    private static let tableSymbols = Set(KaTeXCompatibilityTable.symbols.map(\.name))

    private static func typesettable(_ command: String) -> Bool {
        let name = String(command.prefix { $0.isLetter })
        return command != name
            || MTMathAtomFactory.atom(forLatexSymbol: name) != nil
            || tableSymbols.contains(name)
            || aliases[name] != nil
    }

    // A braced argument (one level of nesting) or a single token, as TeX reads it
    private static let pmod = try! NSRegularExpression(
        pattern: #"\\pmod\s*(?:\{((?:[^{}]|\{[^{}]*\})*)\}|(\\[A-Za-z]+|[^\s{}\\]))"#
    )

    @MainActor
    static func typesettable(_ latex: String) -> String {
        registerSymbols()
        return rewrite(latex)
    }

    @MainActor
    static func registerSymbols() {
        _ = registration
    }

    @MainActor
    private static let registration: Void = {
        for symbol in KaTeXCompatibilityTable.symbols
        where MTMathAtomFactory.atom(forLatexSymbol: symbol.name) == nil {
            MTMathAtomFactory.add(latexSymbol: symbol.name, value: atom(symbol.character, symbol.kind))
        }
    }()

    // MTMathAtom's initializer isn't public: a factory atom is copied and given the class
    private static func atom(_ character: String, _ kind: KaTeXCompatibilityTable.Kind) -> MTMathAtom {
        if kind == .largeOperator {
            return MTMathAtomFactory.operatorWithName(character, limits: false)
        }
        let template: MTMathAtom = MTMathAtomFactory.atom(forCharacter: "=")!
        let atom: MTMathAtom = template.copy()
        atom.nucleus = character
        atom.type = switch kind {
        case .relation: .relation
        case .binaryOperator: .binaryOperator
        case .ordinary: .ordinary
        case .variable: .variable
        case .open: .open
        case .close: .close
        case .punctuation: .punctuation
        case .largeOperator: .largeOperator
        }
        return atom
    }

    static func rewrite(_ latex: String) -> String {
        let withArguments = pmod.stringByReplacingMatches(
            in: latex,
            range: NSRange(latex.startIndex..., in: latex),
            withTemplate: #"\\;(\\mathrm{mod}\\;$1$2)"#
        )
        return replacingAliases(in: withArguments)
    }

    private static func replacingAliases(in latex: String) -> String {
        var result = ""
        result.reserveCapacity(latex.count)
        var index = latex.startIndex
        var textDepth = 0
        var opensText = false
        while index < latex.endIndex {
            let character = latex[index]
            if character == "{", opensText || textDepth > 0 {
                textDepth += 1
                opensText = false
            } else if character == "}", textDepth > 0 {
                textDepth -= 1
            } else if !character.isWhitespace {
                opensText = false
            }
            guard character == "\\" else {
                if textDepth == 0, !character.isASCII, let command = unicode[character] {
                    // The space ends the command before a following letter: αb is \alpha b
                    result += "\\" + command + " "
                } else {
                    result.append(character)
                }
                index = latex.index(after: index)
                continue
            }
            let nameStart = latex.index(after: index)
            var nameEnd = nameStart
            while nameEnd < latex.endIndex, latex[nameEnd].isASCII, latex[nameEnd].isLetter {
                nameEnd = latex.index(after: nameEnd)
            }
            guard nameEnd > nameStart else {
                // A control symbol, `\\` included, so the letters after a line break stay letters
                result.append(character)
                if nameStart < latex.endIndex {
                    result.append(latex[nameStart])
                    index = latex.index(after: nameStart)
                } else {
                    index = nameStart
                }
                continue
            }
            let name = String(latex[nameStart..<nameEnd])
            opensText = name == "text"
            if let alias = aliases[name] {
                result += alias
                if name == "operatorname", nameEnd < latex.endIndex, latex[nameEnd] == "*" {
                    nameEnd = latex.index(after: nameEnd)
                }
            } else {
                result += "\\" + name
            }
            index = nameEnd
        }
        return result
    }
}

#endif
