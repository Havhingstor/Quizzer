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
            case 3..<(maxIndexWithOptions + 1):
                return "Hide Option \(getChar(stage: stage - 1))"
            case maxIndexWithOptions + 1:
                return "Hide solution"
            case maxIndexOverall:
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
            case 2..<maxIndexWithOptions:
                return "Show Option \(getChar(stage: stage))"
            default:
                return "Next"
        }
    }
    
    var showSolutionButtonText: String {
        let stage = currentState.questionStage
        switch stage {
            case maxIndexWithOptions:
                return "Show solution"
            case maxIndexWithOptions + 1:
                return "Show soultion Image"
            default:
                return "Next"
        }
    }
    
    var didBet: Bool {
        currentState.getTeams().filter { team in
            team.betPts == nil
        }.count == 0
    }
    
    let maxIndexPreOption = 2
    
    var maxIndexWithOptions: Int {
        maxIndexPreOption + (question?.options.count ?? 0)
    }
    
    var maxIndexOverall: Int {
        if question?.solutionImage != nil {
            maxIndexWithOptions + 2
        } else {
            maxIndexWithOptions + 1
        }
    }
    
    func getChar(stage: Int) -> String {
        let firstCharIndex = maxIndexPreOption + 1
        let index = UInt(abs(stage - firstCharIndex))
        return MasterQuestion.getAlphabeticalNr(for: index)
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(backButtonText) {
                    withAnimation {
                        if currentState.questionStage == (4 + (question?.options.count ?? 0)) {
                            currentState.currentImage = nil
                        }
                        currentState.questionStage -= 1
                    }
                }
                .disabled(currentState.questionStage < 1)
                Button(nextButtonText) {
                    withAnimation {
                        currentState.questionStage += 1
                    }
                }
                .disabled(currentState.questionStage >= maxIndexWithOptions || (currentState.questionStage == 1 && !currentState.allTeamsHaveBet))
            }
            Button(showSolutionButtonText) {
                withAnimation {
                    if currentState.questionStage == (3 + (question?.options.count ?? 0)) {
                        currentState.currentImage = question?.solutionImage
                    }
                    currentState.questionStage += 1
                }
            }
            .hide(if: currentState.questionStage < maxIndexWithOptions)
            .disabled(currentState.questionStage >= maxIndexOverall)
        }
        .animation(.none, value: currentState.questionStage)
    }
}
