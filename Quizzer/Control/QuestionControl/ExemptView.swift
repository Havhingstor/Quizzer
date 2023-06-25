import SwiftUI

struct ExemptView: View {
    @EnvironmentObject private var currentState: CurrentState
    
    @Binding var question: Question?
    var isQL: Bool
    
    var body: some View {
        if var question {
            if isQL {
                Button("Mark as \(question.exempt ? "Not " : "")Exempt") {
                    withAnimation {
                        question.exempt.toggle()
                        if question.exempt && currentState.currentQuestionResolved?.id == question.id {
                            currentState.currentQuestion = nil
                        }
                    }
                }
                .animation(.none, value: question.exempt)
                .padding()
            }
        }
    }
}
