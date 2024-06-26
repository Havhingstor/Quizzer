import SwiftUI

struct HeaderView: View {
    @EnvironmentObject private var currentState: CurrentState
    
    @Binding var question: Question?
    @Binding var team: Team
    
    var categoryAndPoints: String {
        if let question {
            return "\(question.categoryObject?.name ?? "N/A") - \(question.weight * currentState.storageContainer.baseScore)"
        } else {
            return ""
        }
    }
    
    var body: some View {
        if question != nil {
            Text(categoryAndPoints)
                .font(.largeTitle)
                .padding()
            
            VStack {
                Text("Team")
                Picker("Team", selection: $team) {
                    ForEach(currentState.getTeams()) { team in
                        Text("\(team.name)").tag(team)
                    }
                }
                .labelsHidden()
            }
            .padding()
        }
    }
}

