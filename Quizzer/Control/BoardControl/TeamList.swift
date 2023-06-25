import SwiftUI

struct TeamList: View {
    @EnvironmentObject private var currentState: CurrentState
    
    @State private var teamDeletionAlert = (team: nil as Team?, isShown: false)
    @State private var teamInfoPanel: TeamListing? = nil
    
    @Binding var sorting: TeamsView.SortingMethod
    
    var teamListSorted: [Team] {
        switch sorting {
            case .sequence:
                return currentState.getTeams()
            case .ranking:
                return currentState.getTeams().sorted(by: {
                    $0.overallPoints > $1.overallPoints
                })
        }
    }
    
    var body: some View {
        VStack {
            Text("Team List")
            List {
                ForEach(teamListSorted) { team in
                    TeamListItem(team: team, teamInfoPanel: $teamInfoPanel, teamDeletionAlert: $teamDeletionAlert)
                }
                .onMove( perform: sorting == .sequence ? { from, to in
                    currentState.moveTeams(from: from, to: to)
                } : nil)
                .confirmationDialog("The Team has solved Questions", isPresented: $teamDeletionAlert.isShown) {
                    TeamDeletionConfirmation(teamToDelete: $teamDeletionAlert.team)
                }
            }
            .animation(.default, value: teamListSorted)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .popover(item: $teamInfoPanel) { teamListing in
                TeamInfoPanel(teamListing: teamListing)
            }
        }
    }
}

#Preview {
    TeamList(sorting: .constant(.sequence))
        .environmentObject(CurrentState.examples)
}
