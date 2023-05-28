import SwiftUI
import QuickLook

struct BoardControl: View {
    @EnvironmentObject var currentState: CurrentState

    func canCategoryBeShown() -> Bool {
        for category in currentState.categories {
            if !category.isShown {
                return true
            }
        }

        return false
    }

    func showNextCategory() {
        for (index, category) in currentState.categories.enumerated() {
            if !category.isShown {
                withAnimation {
                    currentState.categories[index].isShown.toggle()
                }
                return
            }
        }
    }

    var body: some View {
        HStack(spacing: 20) {
            List {
                ForEach($currentState.categories) { $category in
                    CategoryListing(category: $category)
                }
            }

            Button("Show next category") {
                showNextCategory()
            }
            .keyboardShortcut("#", modifiers: [])
            .disabled(!canCategoryBeShown())
        }
        .padding()
        .frame(width: 475)
    }
}

struct CategoryListing: View {
    @EnvironmentObject var currentState: CurrentState

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

    var body: some View {
        Section {
            ForEach($currentState.questions) { $question in
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
                }
        }
    }
}

struct QuestionListing: View {
    @EnvironmentObject var currentState: CurrentState
    @Environment(\.openWindow) var openWindow

    @Binding var question: Question
    
    var category: Category {
        currentState.categories.first(where: { $0.id == question.category })!
    }

    var buttonTitle: String {
        let category = question.category
        let totalScore = Int(question.weight) * currentState.baseScore
        let answered: String
        if question.exempt {
            answered = "Exempt"
        } else if question.answered {
            answered = "Answered"
        } else {
            answered = "Unanswered"
        }

        return "\(category) - \(totalScore) - \(answered)"
    }

    var body: some View {
        Button(buttonTitle) {
            withAnimation {
                currentState.currentQuestion = $question
                currentState.questionStage = 0
            }
            openWindow(id: "qst")
        }
        .disabled(!category.isShown || !question.shouldOpen)
        .contextMenu {
            if category.isShown {
                if !question.shouldOpen {
                    Button("Open Question") {
                        withAnimation {
                            currentState.currentQuestion = $question
                            currentState.questionStage = 0
                        }
                        openWindow(id: "qst")
                    }
                }
                Button("Mark as \(getAnswerToggleStr())") {
                    withAnimation {
                        if question.exempt {
                            question.exempt = false
                        } else if question.answered {
                            question.givenAnswer = nil
                        } else {
                            question.exempt = true
                        }
                    }
                }
                Button("Quick Look") {
                    openingQL = true
                    openWindow(value: question)
                }
            }
        }
    }
    
    func getAnswerToggleStr() -> String {
        if question.exempt {
            return "Not Exempt"
        } else if question.answered {
            return "Unanswered"
        } else {
            return "Exempt"
        }
    }
}
