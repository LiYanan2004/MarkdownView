import SwiftUI

struct TextView: View {
    var text: String
    @State private var subText: [String] = []
    var processor = RendererProcessor.main
    
    var body: some View {
        Group {
            if text.isEmpty != subText.isEmpty {
                // An invisible placeholder which is
                // used to let SwiftUI execute `updateContent`
                Color.black.opacity(0.001)
            } else {
                ForEach(subText.indices, id: \.self) { i in
                    Text(subText[i])
                }
            }
        }
        .task(id: text) {
            Task.detached {
                await updateContent()
            }
        }
    }
    
    @Sendable func updateContent() async {
        let splittedText = await RendererProcessor.main.splitText(text)
        await MainActor.run {
            subText = splittedText
        }
    }
}
