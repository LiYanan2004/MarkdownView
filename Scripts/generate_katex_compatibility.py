#!/usr/bin/env python3
"""Generate KaTeXCompatibilityTable.swift: the LaTeX that KaTeX supports and SwiftMath doesn't.

KaTeX's own sources are the reference for what people and AI assistants write as math on the
web. This reads its symbol table and its macros and keeps what SwiftMath can be taught:

- symbols: a command that is one Unicode character with a math class (`\\leqslant` is ⩽, a
  relation), registered with SwiftMath's public `MTMathAtomFactory.add(latexSymbol:value:)`;
- macros: a command KaTeX defines as other commands (`\\Reals` is `\\mathbb{R}`), rewritten
  before typesetting, nested macros expanded here.

Commands SwiftMath already knows are left out, so its own definitions win. What can't be
expressed this way (arguments, KaTeX internals, HTML) is left out too: such a formula is shown
as its source. `SwiftMathCompatibilityTests` checks that every entry typesets.

usage: python3 Scripts/generate_katex_compatibility.py [<katex-checkout>]
  Run from the package root after `swift package resolve`. KaTeX's files are downloaded at the
  tag below unless a checkout of that tag is given; SwiftMath is read from .build/checkouts.
"""

import pathlib
import re
import sys
import tempfile
import urllib.request

KATEX_VERSION = "v0.19.0"

# KaTeX's math classes, as SwiftMath atom kinds; spacing and accents need more than a symbol
KINDS = {
    "rel": "relation",
    "bin": "binaryOperator",
    "textord": "ordinary",
    "mathord": "variable",
    "op-token": "largeOperator",
    "open": "open",
    "close": "close",
    "punct": "punctuation",
    # SwiftMath's inner atom must hold a sub-formula (a bare one crashes its typesetter), and
    # KaTeX's inner symbols (\\mathellipsis) are single characters: ordinary
    "inner": "ordinary",
}
GROUP_NAMES = {
    "rel": "rel", "bin": "bin", "textord": "textord", "mathord": "mathord", "op": "op-token",
    "open": "open", "close": "close", "punct": "punct", "inner": "inner",
    "spacing": "spacing", "accent": "accent-token",
}

# Commands that only make sense to KaTeX's own expander or a browser
UNSUPPORTED_IN_EXPANSION = re.compile(
    r"#|@|\\html|\\TextOrMath|\\DOTS|\\mkern|\\kern|\\char|\\raisebox|\\mathrel|\\mathbin"
    r"|\\mathop|\\mathord|\\mathinner|\\mathpunct|\\mathopen|\\mathclose|\\def|\\let|\\expandafter"
    r"|\\noexpand|\\relax|\\mathchoice|\\hbox|\\vbox|\\llap|\\rlap|\\smash|\\phantom|\\operatorname"
)


# The control symbols SwiftMath's parser reads: spaces, escaped braces and bars, line break
SWIFTMATH_CONTROL_SYMBOLS = set(",;! {}|\\")


def unescape(js: str) -> str:
    return re.sub(r"\\u([0-9a-fA-F]{4})", lambda m: chr(int(m.group(1), 16)), js).replace("\\\\", "\\")


def swiftmath_names(sources: pathlib.Path) -> set[str]:
    """Every command name SwiftMath's sources mention: symbols, parser commands, styles."""
    text = "".join(p.read_text() for p in sources.rglob("*.swift"))
    return set(re.findall(r'"([A-Za-z]+)"', text))


def katex_symbols(symbols_ts: str) -> dict[str, tuple[str, str]]:
    found: dict[str, tuple[str, str]] = {}
    pattern = re.compile(
        r'defineSymbol\(math,\s*(\w+),\s*(\w+),\s*"((?:\\.|[^"\\])*)",\s*"\\\\([A-Za-z]+)"'
    )
    for _font, group, character, name in pattern.findall(symbols_ts):
        kind = KINDS.get(GROUP_NAMES.get(group, ""))
        character = unescape(character)
        if kind and character and name not in found:
            found[name] = (character, kind)
    return found


def katex_unicode(symbols_ts: str) -> dict[str, str]:
    """The command KaTeX reads a Unicode character typed into math as (`≤` is `\\leq`): the
    entries its symbol table marks as accepting the character itself."""
    found: dict[str, str] = {}
    pattern = re.compile(
        r'defineSymbol\(math,\s*\w+,\s*\w+,\s*"((?:\\.|[^"\\])*)",\s*"\\\\([A-Za-z]+)",\s*true\)'
    )
    for character, name in pattern.findall(symbols_ts):
        character = unescape(character)
        if len(character) == 1 and not character.isascii():
            found.setdefault(character, name)
    return found


def katex_macros(macros_ts: str) -> dict[str, str]:
    found: dict[str, str] = {}
    pattern = re.compile(r'defineMacro\("\\\\([A-Za-z]+)",\s*"((?:\\.|[^"\\])*)"\)')
    for name, expansion in pattern.findall(macros_ts):
        found.setdefault(name, unescape(expansion))
    return found


def expand(expansion: str, macros: dict[str, str], depth: int = 0) -> str | None:
    """A macro's expansion with the macros inside it expanded, or None if it can't be said."""
    if depth > 8 or UNSUPPORTED_IN_EXPANSION.search(expansion):
        return None

    def substitute(match: re.Match) -> str:
        inner = match.group(1)
        if inner in macros:
            nested = expand(macros[inner], macros, depth + 1)
            if nested is None:
                raise ValueError(inner)
            return "{" + nested + "}"
        return match.group(0)

    try:
        return re.sub(r"\\([A-Za-z]+)", substitute, expansion).strip()
    except ValueError:
        return None


def swift_string(value: str) -> str:
    """A Swift literal for the value: raw when it holds backslashes or quotes, with enough #
    that nothing inside reads as its delimiter or as a raw escape (`\\#`)."""
    if "\\" not in value and '"' not in value:
        return f'"{value}"'
    hashes = "#"
    while f'"{hashes}' in value or f"\\{hashes}" in value:
        hashes += "#"
    return f'{hashes}"{value}"{hashes}'


def katex_examples(support_table: str) -> dict[str, str]:
    """Each letter command KaTeX supports, with the example its support table renders."""
    examples: dict[str, str] = {}
    for row in support_table.splitlines():
        if not row.startswith("|\\") or "ot supported" in row:
            continue
        cells = row.strip().strip("|").split("|")
        name = re.fullmatch(r"\\\\?([A-Za-z]+)\*?", cells[0].strip())
        rendered = re.fullmatch(r"\$(.+)\$", cells[1].strip()) if len(cells) > 1 else None
        if name and rendered:
            examples.setdefault(name.group(1), rendered.group(1))
    return examples


def write_examples(examples: dict[str, str], output: pathlib.Path) -> None:
    lines = [
        "//",
        f"//  Generated by Scripts/generate_katex_compatibility.py from KaTeX {KATEX_VERSION}'s",
        "//  docs/support_table.md (MIT, see LICENSES/KaTeX-LICENSE). Do not edit: regenerate.",
        "//",
        "",
        "let katexExamples: [(command: String, example: String)] = [",
    ]
    lines += [f'    ("{name}", {swift_string(example)}),' for name, example in sorted(examples.items())]
    lines += ["]", ""]
    output.write_text("\n".join(lines))
    print(f"{len(examples)} KaTeX examples -> {output}")


PACKAGE = pathlib.Path(__file__).resolve().parent.parent
SWIFTMATH = PACKAGE / ".build/checkouts/SwiftMath/Sources/SwiftMath"
TABLE = PACKAGE / "Sources/MarkdownView/Rendering/Shared/Math/KaTeXCompatibilityTable.swift"
EXAMPLES = PACKAGE / "Tests/MarkdownViewTests/Support/KaTeXExamples.swift"
KATEX_FILES = ("src/symbols.ts", "src/macros.ts", "docs/support_table.md")


def katex_checkout() -> pathlib.Path:
    if len(sys.argv) > 1:
        return pathlib.Path(sys.argv[1])
    folder = pathlib.Path(tempfile.mkdtemp(prefix="katex-"))
    for name in KATEX_FILES:
        url = f"https://raw.githubusercontent.com/KaTeX/KaTeX/{KATEX_VERSION}/{name}"
        (folder / name).parent.mkdir(parents=True, exist_ok=True)
        with urllib.request.urlopen(url) as response:
            (folder / name).write_bytes(response.read())
    return folder


def main() -> None:
    katex = katex_checkout()
    if not SWIFTMATH.is_dir():
        sys.exit(f"SwiftMath not found at {SWIFTMATH}: run `swift package resolve` first")
    swiftmath, output = SWIFTMATH, TABLE
    write_examples(katex_examples((katex / "docs/support_table.md").read_text()), EXAMPLES)
    known = swiftmath_names(swiftmath)
    symbols = {
        name: value
        for name, value in katex_symbols((katex / "src/symbols.ts").read_text()).items()
        if name not in known
    }
    unicode = katex_unicode((katex / "src/symbols.ts").read_text())
    macros_all = katex_macros((katex / "src/macros.ts").read_text())
    macros = {}
    for name, expansion in sorted(macros_all.items()):
        if name in known or name in symbols:
            continue
        expanded = expand(expansion, macros_all)
        # Only what SwiftMath, taught the symbols above, can typeset on its own: its commands,
        # its control symbols, and braces that balance (\\bgroup alone is half a group)
        if (
            expanded
            and all(
                command in known or command in symbols
                for command in re.findall(r"\\([A-Za-z]+)", expanded)
            )
            and all(symbol in SWIFTMATH_CONTROL_SYMBOLS for symbol in re.findall(r"\\([^A-Za-z])", expanded))
            and expanded.count("{") == expanded.count("}")
        ):
            macros[name] = expanded

    lines = [
        "//",
        "//  KaTeXCompatibilityTable.swift",
        "//  MarkdownView",
        "//",
        f"//  Generated by Scripts/generate_katex_compatibility.py from KaTeX {KATEX_VERSION}",
        "//  (MIT, see LICENSES/KaTeX-LICENSE). Do not edit.",
        "//",
        "",
        "#if ENABLE_MATH_RENDERING",
        "",
        "enum KaTeXCompatibilityTable {",
        "    enum Kind {",
        "        case relation, binaryOperator, ordinary, variable, largeOperator, open, close, punctuation",
        "    }",
        "",
        "    static let symbols: [(name: String, character: String, kind: Kind)] = [",
    ]
    for name, (character, kind) in sorted(symbols.items()):
        lines.append(f'        ("{name}", {swift_string(character)}, .{kind}),')
    lines += [
        "    ]",
        "",
        "    static let macros: [String: String] = [",
    ]
    for name, expansion in sorted(macros.items()):
        lines.append(f'        "{name}": {swift_string(expansion)},')
    lines += [
        "    ]",
        "",
        "    static let unicode: [Character: String] = [",
    ]
    for character, name in sorted(unicode.items()):
        lines.append(f'        {swift_string(character)}: "{name}",')
    lines += ["    ]", "}", "", "#endif", ""]
    output.write_text("\n".join(lines))
    print(f"{len(symbols)} symbols, {len(macros)} macros, {len(unicode)} characters -> {output}")


if __name__ == "__main__":
    main()
