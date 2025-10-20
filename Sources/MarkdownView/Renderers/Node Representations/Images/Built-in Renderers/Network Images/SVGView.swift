import SwiftUI

// MARK: - SVGView

struct SVGView: View {
    var svg: SVG
    
    @State private var actualSize = CGSize.zero
    @State private var viewWidth = CGFloat.zero
   
    var body: some View {
        HTMLView(svg.htmlRepresentation) { webView in
            webView.evaluateJavaScript("(() => { const svg = document.querySelector('svg'); return svg.hasAttribute('width') ? svg.getBoundingClientRect().width : null; })()") { result, _ in
                if let width = (result as? NSNumber)?.doubleValue, width.isNormal {
                    actualSize.width = width
                }
            }
            webView.evaluateJavaScript("document.querySelector('svg').getBoundingClientRect().height") { result, _ in
                if let height = (result as? NSNumber)?.doubleValue, height.isNormal {
                    actualSize.height = height
                }
            }
        }
        .disabled(disableInteractions)
        .frame(maxWidth: actualSize.width == .zero ? .infinity : actualSize.width)
        .frame(height: actualSize.height)
        .widthOfView($viewWidth)
    }
    
    private var disableInteractions: Bool {
        // Disable scrolling and bounces if the width of the SVGView
        // is greater than or equal to the content width.
        viewWidth >= actualSize.width
    }
}

// MARK: - SVG Helpers

struct SVG: Identifiable, Hashable {
    
    var id = UUID()
    var htmlRepresentation: String
    
    init?(from string: String) {
        let string = string.removeCommentsAndXMLDescription()
        if string.starts(with: "<svg") {
            self.init(html: string)
        } else {
            return nil
        }
    }
    
    private init(html: String) {
        // Remove test cases to enable WKWebview to render SVG content.
        var representation = "<!DOCTYPE html><html><head><meta name=viewport content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0'></head><body style='margin:0;padding:0;background-color:transparent;'><div id='svg_content' style=''>\(html)</div></body></html>"
        let testCases = representation.getElementsByTagName("d:SVGTestCase")
        for testCase in testCases {
            representation = representation.replacingOccurrences(of: testCase, with: "")
        }
        self.htmlRepresentation = representation
    }
}

fileprivate extension String {
    /// Get the specific tag from raw HTML.
    /// - Parameter tag: The string of the tag's name.
    /// - Returns: A set of DOMs, contains all raw HTMLs of the tag.
    func getElementsByTagName(_ tag: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: "<\(tag)[\\s\\S]+?/\(tag)>", options: NSRegularExpression.Options.allowCommentsAndWhitespace) else { return [] }
        let matches = regex.matches(in: self, range: NSRange(location: 0, length: self.count))
        
        var DOMs = [String]()
        for match in matches {
            guard let range = Range(match.range, in: self) else { continue }
            DOMs.append(String(self[range]))
        }
        
        return DOMs
    }
    
    /// Extract size values from the output of the script.
    /// - Returns: A size value for width or height transformed from the CSS.
    func htmlSize() -> Double? {
        Double(
            self
                .replacingOccurrences(of: "px", with: "")
                .replacingOccurrences(of: "em", with: "")
                .replacingOccurrences(of: "pt", with: "")
        )
    }
    
    /// Remove comments and the XML description from the raw HTML to improve SVG detection.
    /// - Returns: A string without HTML comments and the XML description.
    func removeCommentsAndXMLDescription() -> String {
        guard let regex = try? NSRegularExpression(pattern: "<![\\s\\S]+?>[\\s]*", options: []) else { return self }
        let matches = regex.matches(in: self, range: NSRange(location: 0, length: self.count))
        
        var result = self
        for match in matches {
            guard let range = Range(match.range, in: self) else { continue }
            result = result.replacingOccurrences(of: self[range], with: "")
        }
        
        if let regex = try? NSRegularExpression(pattern: "<[?]{1}[\\s\\S]*?[?]{1}>[\\s]*", options: []) {
            let matches = regex.matches(in: self, range: NSRange(location: 0, length: self.count))
            
            for match in matches {
                guard let range = Range(match.range, in: self) else { continue }
                result = result.replacingOccurrences(of: self[range], with: "")
            }
        }
        
        return result
    }
}
