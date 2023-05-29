import QuickLook
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
        HStack(spacing: 20) {
            List {
                ForEach($currentState.categories) { $category in
                    CategoryListing(category: $category)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack {
                VStack {
                    Text("Next Team")
                    Picker("Next Team", selection: $currentState.nextTeam) {
                        ForEach(currentState.getTeams()) { team in
                            Text("\(team.name)")
                                .tag(team)
                        }
                    }
                    .labelsHidden()
                }
                .padding()
                Button("Show next category") {
                    showNextCategory()
                }
                .keyboardShortcut("#")
                .disabled(!canCategoryBeShown())
                .padding()
                Spacer()
                Text("Team List")
                List(currentState.teams) { team in
                    let points = team.overallPoints
                    HStack {
                        Spacer()
                        Text("\(team.name) - \(points) Point(s)\n\(getTeamPosition(team: team)). Place - \(team.solvedQuestions.count) Answer(s)")
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                Spacer()
            }
            .frame(width: 230)
        }
        .padding()
        .frame(width: 350 + 230)
    }

    func getTeamPosition(team: Team) -> Int {
        var position = 1
        for teamIterator in currentState.teams {
            if teamIterator.overallPoints > team.overallPoints {
                position += 1
            }
        }
        if currentState.teams.contains(team) {
            return position
        } else {
            return Int.max
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
        HStack {
            Spacer()
            Button(buttonTitle) {
                withAnimation {
                    currentState.currentQuestion = $question
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
                            currentState.currentQuestion = $question
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
                            if currentState.currentQuestion?.wrappedValue == question {
                                currentState.currentQuestion = nil
                            }
                        }
                    }
                }
            }
            Spacer()
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
