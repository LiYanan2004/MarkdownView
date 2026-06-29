import SwiftUI

struct MarkdownTableBody: View {
    var rows: [MarkdownTableStyleConfiguration.Table.Row]
    @Environment(\.markdownFontGroup.tableBody) private var font

    init(rows: [MarkdownTableStyleConfiguration.Table.Row]) {
        self.rows = rows
    }
    
    var body: some View {
        ForEach(Array(rows.enumerated()), id: \.offset) { (_, row) in
            row.font(font._swiftUIFont)
        }
    }
}
