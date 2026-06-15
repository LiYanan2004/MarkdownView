//
//  MarkdownTextStateTests.swift
//  MarkdownView
//
//  Created by Codex on 2026/6/15.
//

import Foundation
import Testing

@testable import MarkdownView

/// Regression coverage for streamed Markdown updates where the source text is
/// already complete, but `_MarkdownText` can still show a stale rendered result
/// from an older partial update.
@Suite("Markdown Text State")
struct MarkdownTextStateTests {
    @Test
    func markdownContentCacheKeyChangesWithInputText() {
        // Proves the parser/cache key changes with the raw Markdown. If this
        // failed, stale output could come from reusing a rendered document for
        // different source text instead of from `_MarkdownText` state.
        let partialContent = MarkdownContent(raw: .plainText(Self.partialBugMarkdown))
        let finalContent = MarkdownContent(raw: .plainText(Self.bugMarkdown))

        #expect(partialContent != finalContent)
        #expect(partialContent.raw.text == Self.partialBugMarkdown)
        #expect(finalContent.raw.text == Self.bugMarkdown)
    }

    @Test
    @MainActor
    func renderedTextKeepsLatestInputCharacters() {
        // Proves the HTML conversion stage does not truncate the final message.
        // The stale visual text bug happens after this conversion, when the
        // converted result is stored and selected for display.
        let renderedText = _MarkdownText.renderedText(from: AttributedString(Self.bugMarkdown))

        #expect(String(renderedText.characters) == Self.bugMarkdown)
    }

    @Test
    @MainActor
    func olderRenderTaskCannotOverwriteNewerRenderedState() {
        // Simulates the race from streaming updates: the final input renders
        // first, then an older partial render commits later. The visible text
        // must stay on the latest input because rendered state is source-bound.
        let latestInput = AttributedString(Self.bugMarkdown)
        var renderedState: _MarkdownText.RenderedState?

        renderedState = _MarkdownText.renderedState(for: latestInput)
        renderedState = _MarkdownText.renderedState(for: AttributedString(Self.partialBugMarkdown))

        let visibleText = _MarkdownText.visibleText(
            input: latestInput,
            rendered: renderedState
        )

        #expect(String(visibleText.characters) == Self.bugMarkdown)
    }

    @Test
    @MainActor
    func visibleTextUsesLatestInputWhenRenderedStateBelongsToPreviousInput() {
        // Verifies the display decision directly. A cached rendered state for a
        // previous partial input must be ignored when SwiftUI asks the same view
        // identity to display newer text.
        let renderedText = _MarkdownText.renderedState(for: AttributedString(Self.partialBugMarkdown))

        let visibleText = _MarkdownText.visibleText(
            input: AttributedString(Self.bugMarkdown),
            rendered: renderedText
        )

        #expect(String(visibleText.characters) == Self.bugMarkdown)
    }

    @Test
    @MainActor
    func rebuildingViewIdentityShowsLatestInputText() {
        // Documents why forcing a new SwiftUI identity with `.id(...)` masks the
        // bug: the state starts empty, so `_MarkdownText` falls back to the
        // current input before any async render finishes.
        let rebuiltVisibleText = _MarkdownText.visibleText(
            input: AttributedString(Self.bugMarkdown),
            rendered: nil
        )
        #expect(String(rebuiltVisibleText.characters) == Self.bugMarkdown)
    }
}

private extension MarkdownTextStateTests {
    // A realistic partial stream chunk captured from the reported failure. The
    // missing tail starts after the ticket example.
    static let partialBugMarkdown = """
    ## 翻譯與理解

    這句日文「Root化済み個体、63000円+送料とかで欲しい人いますか？」的意思是：

    「有沒有人想要（這台）已經Root過的裝置，價格是63000日圓加運費之類的？」

    - **Root化済み個体**：已經Root過的裝置（個體）
    - **63000円+送料とかで**：以63000日圓加運費之類的價格
    - **欲しい人いますか？**：有想要的人嗎？

    ## 語法解析

    ### 1. ～済み（すみ）

    - **用法**：「～済み」表示某件事情已經完成。常見於動詞的連用形後面。
    - **例句**：
      - 予約済み（よやくずみ）：已預約
      - 支払い済み（しはらいずみ）：已付款
      - Root化済み（るーとかずみ）：已Root化

    ### 2. 個体（こたい）

    - **用法**：在這裡指「個體」，常用於動物、裝置等單一個體。
    - **例句**：
      - この個体（この こたい）：這個個體
      - 新しい個体（あたらしい こたい）：新的個體

    ### 3. 63000円+送料とかで

    - **用法**：「とか」在這裡有「之類的」的意思，表示價格可能有彈性或只是舉例。
    - **例句**：
      - 1000円とかで売っている（せんえん とか で うっている）：用1000日圓之類的價格在賣
      - 友達とかと行きます（ともだち とか と いきます）：會和朋友之類的人一起去

    ### 4. 欲しい人いますか？

    - **用法**：「欲しい（ほしい）」是「想要」的意思，「人」指人，「いますか」是「有嗎」的意思。
    - **例句**：
      - チケットが欲しい人いますか？（ちけっと が ほしい ひと いますか）：有想要票的人嗎？
    """

    // The final stream content. Tests compare against this value to ensure the
    // UI-facing text never regresses to `partialBugMarkdown`.
    static let bugMarkdown = partialBugMarkdown + """

      - これが欲しい人は手を挙げてください（これ が ほしい ひと は て を あげて ください）：想要這個的人請舉手

    ## 其他值得注意的知識點

    - **Root化**：這是來自英文「Root」，指Android裝置取得最高權限。
    - **とか**：在口語中常用來表示舉例、列舉或語氣上的緩和，讓語句聽起來不那麼生硬。
    - **で**：這裡是表示「以～（價格）」的意思。

    希望這樣的解析能幫助你更好理解這句日文的用法！
    """
}
