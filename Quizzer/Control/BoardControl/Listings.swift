import SwiftUI

struct CategoryListing: View {
    @EnvironmentObject private var currentState: CurrentState
    
    @State private var addQuestionShown = false
    @State private var editCategory = false
    
    @Binding var category: Category
    
    func isNextCategory() -> Bool {
        for categoryIterator in currentState.categories {
            if category.id == categoryIterator.id {
                return !categoryIterator.isShown
            } else if !categoryIterator.isShown {
                return false
            }
        }
        return false
    }
    
    private var sortedList: [Binding<Question>] {
        $currentState.questions.sorted { lhs, rhs in
            lhs.weight.wrappedValue < rhs.weight.wrappedValue
        }
    }
    
    var body: some View {
        Section {
            ForEach(sortedList) { $question in
                if question.category == category.id {
                    QuestionListing(question: $question)
                }
            }
        } header: {
            Text("\(category.name) - \(category.isShown ? "Shown" : "Hidden")")
                .foregroundStyle(isNextCategory() ? AnyShapeStyle(Color.red) : AnyShapeStyle(ForegroundStyle.foreground))
                .contextMenu {
                    Button("\(category.isShown ? "Hide" : "Show") category") {
                        withAnimation {
                            category.isShown.toggle()
                        }
                    }
                    Button("Edit Category") {
                        editCategory = true
                    }
                    Button("Delete Category", role: .destructive) {
                        withAnimation {
                            currentState.deleteCategory(category)
                        }
                    }
                    Button("Add Question") {
                        addQuestionShown = true
                    }
                }
                .sheet(isPresented: $addQuestionShown) {
                    AddQuestionView(questionType: .question(category: category))
                }
                .sheet(isPresented: $editCategory) {
                    NameSelectionSheet(groundType: "New Category", typeOfInteraction: "Change") { newName in
                        if category.name == newName {
                            return
                        } else if currentState.categories.contains(where: { item in
                            item.name == newName
                        }) {
                            throw QuizError.categoryNameAlreadyExists
                        } else {
                            currentState.editCategory(category, newName: newName)
                        }
                    }
                }
        }
    }
}

struct QuestionListing: View {
    @EnvironmentObject private var currentState: CurrentState
    @Environment(\.openWindow) private var openWindow
    
    @State var questionDeletionAlertShown = false
    @State var questionEditSheet = false
    
    @Binding var question: Question
    
    var category: Category? {
        currentState.categories.first(where: { $0.id == question.category })
    }
    
    var buttonTitle: String {
        guard let category = question.categoryObject else { return "N/A" }
        let totalScore = question.weight * currentState.baseScore
        let answered: String
        if question.exempt {
            answered = "Exempt"
        } else if question.answered {
            answered = "Answered"
        } else {
            answered = "Unanswered"
        }
        
        return "\(category.name) - \(totalScore) - \(answered)"
    }
    
    func deleteQuestion() {
        withAnimation {
            currentState.deleteQuestion(question)
        }
    }
    
    var body: some View {
        if let category {
            HStack {
                Spacer()
                Button(buttonTitle) {
                    withAnimation {
                        currentState.currentQuestion = currentState.getIndexOfQuestion(question)
                    }
                    openWindow(id: "qst")
                }
                .animation(.none, value: question.answered)
                .animation(.none, value: question.exempt)
                .disabled(!category.isShown || !question.shouldOpen)
                .contextMenu {
                    if question.answered {
                        Button("Open Question") {
                            withAnimation {
                                currentState.currentQuestion = currentState.getIndexOfQuestion(question)
                            }
                            openWindow(id: "qst")
                        }
                    }
                    Button("Quick Look") {
                        openWindow(value: question)
                    }
                    Button("\(getAnswerToggleStr())") {
                        withAnimation {
                            if question.exempt {
                                question.exempt = false
                            } else if question.answered {
                                question.givenAnswer = nil
                            } else {
                                question.exempt = true
                                if currentState.currentQuestionResolved == question {
                                    currentState.currentQuestion = nil
                                }
                            }
                        }
                    }
                    Button("Edit Question") {
                        questionEditSheet = true
                    }
                    Button("Delete Question", role: .destructive) {
                        if question.answered {
                            questionDeletionAlertShown = true
                        } else {
                            deleteQuestion()
                        }
                    }
                }
                .alert("Question has answer", isPresented: $questionDeletionAlertShown) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete anyway", role: .destructive) {
                        deleteQuestion()
                    }
                }
                .sheet(isPresented: $questionEditSheet) {
                    AddQuestionView(question: $question)
                }
                Spacer()
            }
        }
    }
    
    func getAnswerToggleStr() -> String {
        if question.exempt {
            return "Mark As Not Exempt"
        } else if question.answered {
            return "Remove Answer"
        } else {
            return "Mark As Exempt"
        }
    }
}
