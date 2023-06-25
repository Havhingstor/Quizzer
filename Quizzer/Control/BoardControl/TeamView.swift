import SwiftUI

struct TeamView: View {
    enum SortingMethod {
        case sequence
        case ranking
    }
    
    @EnvironmentObject private var currentState: CurrentState
    @Environment(\.openWindow) var openWindow
    
    @State private var sorting = SortingMethod.sequence
    
//    @State private var shownTeam: TeamListing?
//    @State private var teamDeletionAlertShown = false
//    @State private var teamToDelete: Team?
    @State private var addTeamSheet = false
    @State private var newTeamName = ""
    @State private var teamAdditionAlert = false
    
    var body: some View {
        TeamList(sorting: $sorting)
        .overlay(alignment: .topLeading) {
            Button {
                addTeamSheet = true
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.borderless)
            .padding(2)
            .sheet(isPresented: $addTeamSheet) {
                VStack(spacing: 20) {
                    TextField("Team Name", text: $newTeamName)
                        .onSubmit {
                            do {
                                try currentState.addTeam(name: newTeamName)
                            } catch {
                                teamAdditionAlert = true
                            }
                            newTeamName = ""
                            addTeamSheet = false
                        }
                    Button("Add") {
                        do {
                            try currentState.addTeam(name: newTeamName)
                        } catch {
                            teamAdditionAlert = true
                        }
                        newTeamName = ""
                        addTeamSheet = false
                    }
                }
                .padding()
            }
            .alert("This Name already exists!", isPresented: $teamAdditionAlert) {
                Button("OK", role: .cancel) {
                    newTeamName = ""
                    addTeamSheet = false
                }
            }
        }
        .overlay(alignment: .topTrailing) {
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
    }
}

#Preview {
    TeamView()
        .environmentObject(CurrentState.examples)
}
