import SwiftUI

package struct MarkdownTableBody: View {
    package var rows: [MarkdownTableStyleConfiguration.Table.Row]
    @Environment(\.markdownFontGroup.tableBody) private var font

    package init(rows: [MarkdownTableStyleConfiguration.Table.Row]) {
        self.rows = rows
    }
    
    package var body: some View {
        ForEach(Array(rows.enumerated()), id: \.offset) { (_, row) in
            row.font(Font(font.asPlatformFont))
        }
    }
}
