import SwiftUI

struct MasterQuestionControl: View {
    @EnvironmentObject var currentState: CurrentState
    
    @Binding var question: MasterQuestion?
    
    var body: some View {
        if let question {
            VStack(alignment: .center) {
                Text("Master Question")
                    .font(.largeTitle)
                    .padding()
                
                MasterQuestionAndAnswer(question: $question)
                
                
                
                //            PresentationControls(holder: holder, question: $question)
                //
                //            Group {
                //                AnswerControl(holder: holder, question: $question, answer: $answer, team: team, goToControl: goToControl, registerAnswer: registerAnswer)
                //
                //                PreviousAnswer(holder: holder, question: $question, answer: $answer, teamInternal: $teamInternal, goToControl: goToControl)
                //            }
                //            .hide(if: question.exempt)
                //
                //            ExemptView(holder: holder, question: $question)
            }
            .padding()
            .frame(minWidth: 350)
            .fixedSize()
            .onAppear {
                currentState.showMasterQuestion = true
                currentState.isInStartStage = false
            }
        }
    }
}

struct MasterQuestionAndAnswer: View {
    @Binding var question: MasterQuestion?
    
    var body: some View {
        if let question {
            GroupBox {
                VStack {
                    Text("Question")
                    Text(question.question)
                        .font(.headline)
                        .italic()
                }
                .padding([.bottom, .leading, .trailing])
                
                VStack {
                    Text("True Answer")
                    Text("\(question.answer)")
                        .font(.headline)
                        .italic()
                }
            } label: {
                Text("Question &\nTrue Answer")
                    .multilineTextAlignment(.center)
                    .font(.title2)
            }
            .padding()
        }
    }
}
