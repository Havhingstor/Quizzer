import SwiftUI

struct MasterQuestionBettingView: View {
    @EnvironmentObject private var currentState: CurrentState
    
    var body: some View {
        VStack {
            Text("Bets")
                .font(.title2)
            ScrollView {
                ForEach(currentState.getTeams()) { team in
                    HStack {
                        Spacer()
                        BetTextView(team: team)
                        Spacer()
                    }
                }
            }
            .hide(if: currentState.questionStage < 1)
        }
        .padding(.top)
    }
}

struct BetTextView: View {
    @ObservedObject var team: Team
    
    var body: some View {
        VStack {
            Text(team.name)
                .font(.title3)
            Text("Available: \(team.overallPoints)")
            TextField("Bet", value: $team.betPts, format: .number)
                .frame(width: 100)
                .multilineTextAlignment(.center)
        }
        .padding(5)
        
    }
}

