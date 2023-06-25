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
    
    func getTeamPosition(team: Team) -> Int {
        var position = 1
        for teamIterator in currentState.getTeams() {
            if teamIterator.overallPoints > team.overallPoints {
                position += 1
            }
        }
        if currentState.getTeams().contains(team) {
            return position
        } else {
            return Int.max
        }
    }
    
    func showTeamInfo(team: Team) {
        teamInfoPanel = TeamListing(team: team, answers: team.solvedQuestions)
    }
    
    var body: some View {
        VStack {
            Text("Team List")
            List {
                ForEach(teamListSorted) { team in
                    let points = team.overallPoints
                    HStack {
                        Spacer()
                        Text("\(team.name) - \(points) Point(s)\n\(getTeamPosition(team: team)). Place - \(team.solvedQuestions.count) Answer(s)")
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke())
                    .overlay(alignment: .topTrailing) {
                        Button {
                            showTeamInfo(team: team)
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .buttonStyle(.borderless)
                        .padding([.top, .trailing], 7)
                    }
                    .padding(2)
                    .contextMenu {
                        Button("Show Team") {
                            showTeamInfo(team: team)
                        }
                        Button("Delete", role: .destructive) {
                            if team.solvedQuestions.count > 0 {
                                teamDeletionAlert.team = team
                                teamDeletionAlert.isShown = true
                            } else {
                                currentState.deleteTeam(team: team)
                            }
                        }
                    }
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
