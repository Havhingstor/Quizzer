import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject private var currentState: CurrentState
    
    let width = 300.0
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach($currentState.categories) { $category in
                    CategoryListing(category: $category)
                    Spacer(minLength: 20)
                }
            }
            .padding()
        }
        .frame(width: width)
    }
}

#Preview {
    CategoriesView()
        .environmentObject(CurrentState.examples)
        .fixedSize(horizontal: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, vertical: false)
}
