import SwiftUI

struct TeamListItem: View {
    @EnvironmentObject private var currentState: CurrentState
    
    @ObservedObject var team: Team
    
    @State private var showTeamEdit = false
    
    @Binding var teamInfoPanel: TeamListing?
    @Binding var teamDeletionAlert: (team: Team?, isShown: Bool)
    
    private var points: UInt {
        team.overallPoints
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
            if team != CurrentState.defaultTeam {
                Button("Edit") {
                    showTeamEdit = true
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
        .sheet(isPresented: $showTeamEdit, content: {
            NameSelectionSheet(groundType: "New Team Name", typeOfInteraction: "Change", startText: $team.name) { newName in
                if team.name == newName {
                    return
                } else if currentState.getTeams().contains(where: { item in
                    item.name == newName
                }) {
                    throw QuizError.teamNameAlreadyExists
                }
                
                team.name = newName
            }
        })

    }
}
