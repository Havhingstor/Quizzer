import SwiftUI

struct BoardControl: View {
    var body: some View {
        HStack(spacing: 20) {
            CategoriesView()
            GeneralControl()
        }
        .padding()
    }
}
