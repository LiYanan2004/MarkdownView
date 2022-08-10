import SwiftUI

struct NetworkImage: View {
    var url: URL
    
    var body: some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image.resizable().aspectRatio(contentMode: .fit)
            } else if let error = phase.error {
                SwiftUI.Text(error.localizedDescription)
            } else {
                Rectangle()
                    .foregroundStyle(.quaternary)
                    .aspectRatio(4 / 3, contentMode: .fit)
                    .opacity(0.5)
            }
        }
    }
}

