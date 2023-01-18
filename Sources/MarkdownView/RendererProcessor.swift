import SwiftUI
import Combine

let _markdownRenderComplete = PassthroughSubject<Void, Never>()

actor RendererProcessor {
    static var main = RendererProcessor()
    var renderQueueRemainCount = 0
    
    nonisolated func renderMarkdownView(text: String, config: RendererConfiguration, interactiveHandler: @escaping (String) -> Void) -> AnyView {
        var renderer = Renderer(
            text: text,
            configuration: config,
            interactiveEditHandler: interactiveHandler
        )
        let parseBD = !BlockDirectiveRenderer.shared.blockDirectiveHandlers.isEmpty
        let view = renderer.representedView(parseBlockDirectives: parseBD)
        return view
    }
}

extension RendererProcessor {
    nonisolated func splitText(_ text: String) async -> [String] {
        guard text.count > 0 else { return [] }
        var splittedText = [String]()
        
        /// Splits spaces and adds to `splittedText`
        func addSplittedText(_ text: String) {
            // ASCII contains both lowercased and uppercased english letters,
            // spaces, numbers and punctuations, which are different types of text,
            // so we need to split them out.
            var textArray = subText
                .split(separator: " ", omittingEmptySubsequences: false)
                .map { String($0) }
            var index = 1
            while index <= textArray.count - 1 {
                textArray.insert(" ", at: index)
                index += 2
            }
            
            // Beacuse we don't omit empty subsequences before,
            // there might have some empty strings in the array.
            // To improve the performance of `FlexibleStack`,
            // we need to remove all empty sequences.
            textArray = textArray.compactMap { $0.isEmpty ? nil : $0 }
            
            splittedText.append(contentsOf: textArray)
        }
        
        var subText = ""
        for character in text {
            if !character.isASCII || !(subText.last?.isASCII ?? true) {
                addSplittedText(subText)
                subText = ""
            }
            subText.append(character)
        }

        if !subText.isEmpty {
            addSplittedText(subText)
        }
        
        await finishRendering()
        return splittedText
    }
    
    func finishRendering() {
        renderQueueRemainCount -= 1
        if renderQueueRemainCount <= 0 {
            Task { @MainActor in
                _markdownRenderComplete.send()
            }
        }
    }
    
    func addTextCounter() {
        renderQueueRemainCount += 1
    }
}
