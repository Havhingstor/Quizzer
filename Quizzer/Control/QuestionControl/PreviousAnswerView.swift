import SwiftUI

struct PreviousAnswerView: View {
    @EnvironmentObject var currentState: CurrentState
    
    @Binding var question: Question?
    var isQL: Bool
    
    @Binding var answer: String
    @Binding var teamInternal: Team
    
    var goToControl: () -> Void
    
    var isJoker: Bool {
        question?.question.lowercased() == "joker"
    }
    
    func deleteAnswer() {
        if var question {
            question.givenAnswer = nil
        }
    }
    
    var body: some View {
        if let questionAnswer = question?.givenAnswer {
            GroupBox {
                VStack {
                    Text("Previous Team")
                    Text("\(questionAnswer.team.name)")
                        .font(.headline)
                }
                .padding([.leading, .trailing])
                .onAppear {
                    if let oldTeam = question?.givenAnswer?.team {
                        teamInternal = oldTeam
                    }
                }
                
                if !isJoker {
                    VStack {
                        Text("Previous Answer")
                        let prevAnswer = questionAnswer.answer
                        let pACount = prevAnswer.count
                        Text("\(pACount > 0 ? prevAnswer : "- / -")")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .italic()
                        Text("\(questionAnswer.correct ? "Correct" : "Wrong")")
                    }
                    .padding()
                    .onAppear {
                        answer = questionAnswer.answer
                    }
                }
                
                Button("Remove Answer") {
                    deleteAnswer()
                    goToControl()
                }
            } label: {
                Text("Previous Answer")
                    .font(.title2)
            }
            .padding()
        } else if isQL {
            Text("Not Answered")
                .padding()
        }
    }
}
