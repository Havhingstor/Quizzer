import SwiftUI

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
        HStack {
            List {
                ForEach($currentState.categories) { $category in
                    CategoryListing(category: $category)
                }
            }
            .frame(maxWidth: 300)
            .padding()

            Button("Show next category") {
                showNextCategory()
            }
            .keyboardShortcut("#", modifiers: [])
            .padding()
            .disabled(!canCategoryBeShown())
        }
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
        let answered = question.answered ? "Answered" : "Unanswered"

        return "\(category) - \(totalScore) - \(answered)"
    }

    var body: some View {
        Button(buttonTitle) {
            withAnimation {
                currentState.currentQuestion = $question
            }
            openWindow(id: "qst")
        }
        .disabled(!category.isShown)
        .contextMenu {
            if category.isShown {
                Button("Mark as \(question.answered ? "Unanswered" : "Answered")") {
                    question.answered.toggle()
                }
            }
        }
    }
}
