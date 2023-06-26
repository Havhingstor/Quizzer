import SwiftUI

enum AddedQuestionType {
    case masterQuestion
    case question(category: String)
}

struct AddQuestionView: View {
    @EnvironmentObject private var currentState: CurrentState
    @Environment(\.dismiss) private var dismiss
    
    var questionType: AddedQuestionType
    
    @State private var weight: Int = 0
    @State private var question = ""
    @State private var trueAnswer = ""
    @State private var alreadyExistsErrorShown = false
    
    private var weightPos: UInt {
        return UInt(abs(weight))
    }
    
    func submit() {
        if case let .question(category) = questionType {
            let question = Question(question: question, answer: trueAnswer, category: category, weight: weightPos)
            
            do {
                try withAnimation {
                    try currentState.addQuestion(question: question)
                }
                dismiss()
            } catch {
                alreadyExistsErrorShown = true
            }
        }

    }
    
    var body: some View {
        Form {
            if case let .question(category) = questionType {
                Text("Category: \(category)")
            }
            TextField("Weight:", value: $weight, format: .number)
            Text("Points: \(weightPos * currentState.baseScore)")
            Spacer(minLength: 20)
            TextField("Question:", text: $question)
            TextField("True Answer:", text: $trueAnswer)
            
            Button("Submit") {
                submit()
            }
            .onChange(of: weight) { oldValue, newValue in
                if newValue < 0 {
                    weight = oldValue
                }
            }
        }
        .padding()
        .onSubmit {
            submit()
        }
        .alert("The combination of Category and Weight already exists", isPresented: $alreadyExistsErrorShown) {
            Button("OK") {}
        }
    }
}

#Preview {
        AddQuestionView(questionType: .question(category: "Category"))
            .fixedSize()
            .padding()
            .environmentObject(CurrentState.examples)
}

#Preview {
    AddQuestionView(questionType: .masterQuestion)
        .fixedSize()
        .padding()
        .environmentObject(CurrentState.examples)
}
