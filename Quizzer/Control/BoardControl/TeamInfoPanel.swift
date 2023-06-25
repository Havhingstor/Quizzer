import SwiftUI

struct TeamInfoPanel: View {
    @EnvironmentObject private var currentState: CurrentState
    @Environment(\.openWindow) var openWindow
    
    @State private var teamAddedPoints = 0
    @State private var teamPointsEditing = false
    
    var teamListing: TeamListing
    
    private var team: Team {
        teamListing.team
    }
    
    private var answers: [AnswerListing] {
        teamListing.answers
    }
    
    @ViewBuilder
    private var solvedQuestions: some View {
        Text("Solved Questions - \(team.name)")
        ForEach(answers) { answer in
            let question = answer.question
            Text("\(answer.category) - \(answer.score)\n\(answer.correct ? "Correct" : "Wrong")")
                .fixedSize()
                .onTapGesture {
                    openWindow(value: question)
                }
                .multilineTextAlignment(.center)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke()
                }
                .padding()
        }
    }
    
    @ViewBuilder
    private var addedPoints: some View {
        VStack {
            Text("Added Points:")
            if !teamPointsEditing {
                Text("\(team.addedPoints)")
                    .onTapGesture {
                        withAnimation {
                            teamPointsEditing = true
                        }
                    }
            } else {
                TextField("Added Points", value: $teamAddedPoints, format: .number)
                    .onSubmit {
                        withAnimation {
                            teamPointsEditing = false
                            team.addedPoints = teamAddedPoints
                        }
                    }
                    .labelsHidden()
                    .onAppear {
                        teamAddedPoints = team.addedPoints
                    }
                
            }
        }
        .padding()
    }
    
    var body: some View {
        VStack {
            solvedQuestions
            addedPoints
        }
        .padding()

    }
}
