import Markdown
import SwiftUI

// MARK: - Inline Code Block
extension Renderer {
    mutating func visitInlineCode(_ inlineCode: InlineCode) -> AnyView {
        var subText = [SwiftUI.Text]()
        
        Split(inlineCode.code).forEach {
            subText.append(SwiftUI.Text($0))
        }

        return AnyView(ForEach(subText.indices, id: \.self) { index in
            let roundedSide: WithRoundedCorner.Side = {
                if subText.count == 1 { return .bothSides }
                if index == 0 { return .leading }
                else if index == subText.count - 1 { return .trailing }
                return .none
            }()
            let additionalSpace: CGFloat = {
                if roundedSide == .none { return 0 }
                else if roundedSide == .bothSides { return 10 }
                return 5
            }()
            let blockBackground: GeometryReader = {
                GeometryReader { proxy in
                    let size = proxy.size
                    Rectangle()
                        .fill(.tint.opacity(0.2))
                        .frame(width: size.width + additionalSpace,
                               height: size.height + 5)
                        .withCornerRadius(5, at: roundedSide)
                        .offset(x: roundedSide == .leading || roundedSide == .bothSides ? -5 : 0,
                                y: -2.5)
                }
            }()
            
            subText[index]
                .font(.system(.body, design: .monospaced).bold())
                .background { blockBackground }
                .foregroundStyle(.tint)
                .padding(.vertical, 8)
                .padding(roundedSide.edge, roundedSide == .none ? 0 : 5)
        })
    }
}

// MARK: - Code Block

extension Renderer {
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> AnyView {
        AnyView(VStack(alignment: .trailing, spacing: 0) {
            SwiftUI.Text(codeBlock.code)
                .font(.system(.callout, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
                .overlay(alignment: .bottomTrailing) {
                    if let language = codeBlock.language {
                        SwiftUI.Text(language)
                            .font(.caption)
                            .padding(8)
                            .foregroundStyle(.secondary)
                    }
                }
            PaddingLine()
        })
    }
}
