import SwiftUI

struct QuestionControl: View {
    @EnvironmentObject var currentState: CurrentState
    @Environment(\.dismiss) var dismiss

    var categoryAndPoints: String {
        let question = currentState.currentQuestion!
        return "\(question.wrappedValue.category) - \(Int(question.wrappedValue.weight) * currentState.baseScore)"
    }

    var body: some View {
        if let question = currentState.currentQuestion {
            Form {
                Text(categoryAndPoints)
                    .font(.largeTitle)
                    .padding()

                Section("Question & True Answer") {
                    LabeledContent {
                        Text(question.wrappedValue.question)
                            .italic()
                    } label: {
                        Text("Question")
                    }
                    LabeledContent {
                        Text(question.wrappedValue.answer)
                            .italic()
                    } label: {
                        Text("Answer")
                    }
                }
                .padding()
                
                Section("Received Answer") {
                    Button("Log in correct answer") {
                        question.wrappedValue.answered.toggle()
                        dismiss.callAsFunction()
                    }
                    Button("Log in wrong answer") {
                        question.wrappedValue.answered.toggle()
                        dismiss.callAsFunction()
                    }
                }
            }
        } else {
            Text("No Question")
        }
    }
}

struct QuestionControl_Previews: PreviewProvider {
    static var previews: some View {
        QuestionControl()
    }
}
