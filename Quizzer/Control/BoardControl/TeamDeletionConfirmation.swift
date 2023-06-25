import SwiftUI

struct TeamDeletionConfirmation: View {
    @EnvironmentObject private var currentState: CurrentState
    
    @Binding var teamToDelete: Team?
    
    var body: some View {
        Button("Delete anyway", role: .destructive) {
            guard let teamToDelete else {return}
            
            for (index, question) in currentState.questions.enumerated() {
                if question.givenAnswer?.team == teamToDelete {
                    currentState.questions[index].exempt = true
                }
            }
            
            currentState.deleteTeam(team: teamToDelete)
        }
    }
}

#Preview {
    TeamDeletionConfirmation(teamToDelete: .constant(Team(name: "Test Team")))
}
