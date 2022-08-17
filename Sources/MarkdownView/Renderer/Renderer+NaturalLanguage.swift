import NaturalLanguage

extension Renderer {
    func Split(_ text: String) -> [String] {
        guard text.count > 0 else { return [] }
        
        var subText = [String]()
        
        let tagger = NLTagger(tagSchemes: [.tokenType])
        tagger.string = text
        let options = NLTagger.Options(arrayLiteral: [.omitPunctuation, .omitWhitespace])
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .tokenType, options: options) { _, tokenRange in
            let forwardTextAsArray = Array(text[tokenRange.upperBound...])
            var string = String(text[tokenRange])
            if forwardTextAsArray.isEmpty == false {
                var index = 0
                var forwardChar = forwardTextAsArray[index]
                while (forwardChar.isWhitespace || forwardChar.isPunctuation) && index < forwardTextAsArray.endIndex {
                    string.append(forwardChar)
                    index += 1
                    forwardChar = forwardTextAsArray[min(index, forwardTextAsArray.endIndex - 1)]
                }
            }
            subText.append(string)
            return true
        }
        
        // Fixed: Prefix whitespace or punctuation will not render as expected.
        let textAsArray = Array(text)
        var index = 0
        var forwardChar = textAsArray[index]
        var prefixText = ""
        while (forwardChar.isWhitespace || forwardChar.isPunctuation) && index < textAsArray.endIndex {
            prefixText.append(forwardChar)
            index += 1
            forwardChar = textAsArray[min(index, textAsArray.endIndex - 1)]
        }
        if prefixText.isEmpty == false {
            subText.insert(prefixText, at: 0)
        }
        
        return subText
    }
}
