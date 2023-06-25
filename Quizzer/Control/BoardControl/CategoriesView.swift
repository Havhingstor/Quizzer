import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject private var currentState: CurrentState
    
    @State private var addCategorySheet = false
    
    let width = 300.0
    
    @ViewBuilder
    private var addButton: some View {
        Button {
            addCategorySheet = true
        } label: {
            Image(systemName: "plus")
        }
        .buttonStyle(.borderless)
        .padding(2)
        .sheet(isPresented: $addCategorySheet) {
            NameSelectionSheet(groundType: "Category", additionFunc: currentState.addCategory)
        }
    }
    
    var body: some View {
        List {
            ForEach($currentState.categories) { $category in
                CategoryListing(category: $category)
            }
            .onMove(perform: currentState.moveCategory)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
        .overlay(alignment: .topLeading) {
            addButton
        }
        .frame(width: width)
    }
}

#Preview {
    CategoriesView()
        .environmentObject(CurrentState.examples)
        .fixedSize(horizontal: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, vertical: false)
}
