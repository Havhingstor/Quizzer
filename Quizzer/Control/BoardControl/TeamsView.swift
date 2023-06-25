import SwiftUI

struct TeamsView: View {
    enum SortingMethod {
        case sequence
        case ranking
    }
    
    @EnvironmentObject private var currentState: CurrentState
    @Environment(\.openWindow) private var openWindow
    
    @State private var sorting = SortingMethod.sequence
    @State private var addTeamSheet = false
    
    @ViewBuilder
    private var sortingView: some View {
        Menu("\(sorting == .sequence ? "In Order" : "Ranking")") {
            Picker("Sort", selection: $sorting) {
                Text("In Order")
                    .tag(SortingMethod.sequence)
                Text("Ranking")
                    .tag(SortingMethod.ranking)
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }
    
    @ViewBuilder
    private var addButton: some View {
        Button {
            addTeamSheet = true
        } label: {
            Image(systemName: "plus")
        }
        .buttonStyle(.borderless)
        .padding(2)
        .sheet(isPresented: $addTeamSheet) {
            NameSelectionSheet(groundType: "Team", additionFunc: currentState.addTeam)
        }
    }
    
    var body: some View {
        TeamList(sorting: $sorting)
        .overlay(alignment: .topLeading) {
            addButton
        }
        .overlay(alignment: .topTrailing) {
            sortingView
        }
    }
}

#Preview {
    TeamsView()
        .environmentObject(CurrentState.examples)
}
