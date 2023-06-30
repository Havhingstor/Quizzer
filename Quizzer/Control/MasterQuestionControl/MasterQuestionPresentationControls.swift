import SwiftUI

struct MasterQuestionPresentationControls: View {
    @EnvironmentObject private var currentState: CurrentState
    
    @Binding var question: MasterQuestion?
    
    var backButtonText: String {
        let stage = currentState.questionStage
        switch stage {
            case 1:
                return "Hide Point List"
            case 2:
                return "Go to Prompt Page"
            case 3..<((question?.options.count ?? 0) + 3):
                return "Hide Option \(MasterQuestion.getAlphabeticalNr(for: UInt(stage - 3)))"
            case (question?.options.count ?? 0) + 3:
                return "Hide solution Image"
            default:
                return "Previous"
        }
    }
    
    var nextButtonText: String {
        let stage = currentState.questionStage
        switch stage {
            case 0:
                return "Show Points"
            case 1:
                return "Go to Question Page"
            case 2..<((question?.options.count ?? 0) + 2):
                return "Show Option \(MasterQuestion.getAlphabeticalNr(for: UInt(stage - 2)))"
            case (question?.options.count ?? 0) + 2:
                return "Show solution image"
            default:
                return "Next"
        }
    }
    
    var didBet: Bool {
        currentState.getTeams().filter { team in
            team.betPts == nil
        }.count == 0
    }
    
    var maxIndex: Int {
        if question?.solutionImage != nil {
            (2 + (question!.options.count))
        } else {
            (1 + (question?.options.count ?? 0))
        }
    }
    
    var body: some View {
        HStack {
            Button(backButtonText) {
                withAnimation {
                    if currentState.questionStage == (3 + (question?.options.count ?? 0)) {
                        currentState.currentImage = nil
                    }
                    currentState.questionStage -= 1
                }
            }
            .disabled(currentState.questionStage < 1)
            Button(nextButtonText) {
                withAnimation {
                    if currentState.questionStage == (2 + (question?.options.count ?? 0)) {
                        currentState.currentImage = question?.solutionImage
                    }
                    currentState.questionStage += 1
                }
            }
            .disabled(currentState.questionStage > maxIndex || (currentState.questionStage == 1 && !currentState.allTeamsHaveBet))
        }
        .animation(.none, value: currentState.questionStage)
    }
}
