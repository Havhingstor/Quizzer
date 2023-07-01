import SwiftUI

struct QuestionEditView: View {
    @EnvironmentObject private var currentState: CurrentState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openWindow) private var openWindow
    
    @State private var alreadyExistsErrorShown = false
    @Bindable private var referencedQuestion: QuestionVars
    
    private var editedQuestion = nil as Binding<Question>?
    
    var paramsIllegal: Bool {
        if let editedQuestion,
           editedQuestion.wrappedValue.weight == referencedQuestion.weight,
            editedQuestion.wrappedValue.category == referencedQuestion.category {
            return false
        } else {
            return currentState.testExistenceOfQuestionParams(weight: referencedQuestion.weight, category: referencedQuestion.category)
        }
    }
    
    func submit() {
        if let editedQuestion {
            if paramsIllegal {
                alreadyExistsErrorShown = true
            } else {
                withAnimation {
                    editedQuestion.wrappedValue = referencedQuestion.toQuestion()
                }
                dismiss()
            }
        } else {
            do {
                try withAnimation {
                    try currentState.addQuestion(question: referencedQuestion.toQuestion())
                }
                dismiss()
            } catch {
                alreadyExistsErrorShown = true
            }
        }
        currentState.storageContainer.cleanImages()
    }
    
    init(category: Category) {
        referencedQuestion = QuestionVars(questionObject: Question(question: "", answer: "", category: category, weight: 0))
    }
    
    init(question: Binding<Question>) {
        referencedQuestion = QuestionVars(questionObject: question.wrappedValue)
        editedQuestion = question
    }
    
    var body: some View {
        Form {
            Group {
                Picker("Category", selection: $referencedQuestion.category) {
                    ForEach(currentState.categories) { category in
                        Text("\(category.name)").tag(category.id)
                    }
                }
                TextField("Weight:", value: $referencedQuestion.weight, format: .number)
                Text("Points: \(referencedQuestion.weight * currentState.storageContainer.baseScore)")
                
                Spacer(minLength: 20)
            }
            
            GeneralQuestionEditView(referencedQuestion: referencedQuestion)
            
            Group {
                Text("True Answer:")
                TextEditor(text: $referencedQuestion.answer)
                    .frame(minHeight: 50)
                
                Spacer(minLength: 20)
            }
            
            Group {
                Button("Submit") {
                    submit()
                }
                
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
        }
        .padding()
        .onAppear(perform: {
            guard let category = currentState.categories.first else { return }
            
            referencedQuestion.category = category.id
        })
        .onSubmit {
            submit()
        }
        .alert("The combination of Category and Weight already exists", isPresented: $alreadyExistsErrorShown) {
            Button("OK") {}
        }
        .frame(minWidth: 400)
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview {
    QuestionEditView(category: Category(name: "Test"))
        .fixedSize()
        .padding()
        .environmentObject(CurrentState.examples)
}
