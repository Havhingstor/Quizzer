import SwiftUI

struct BoardControl: View {
    @EnvironmentObject var currentState: CurrentState
    @Environment(\.openWindow) var openWindow

    @State private var shownTeam: TeamListing?
    @State private var teamAddedPoints = 0
    @State private var teamPointsEditing = false
    @State private var teamDeletionAlertShown = false
    @State private var teamToDelete: Team?
    @State private var addTeamSheet = false
    @State private var newTeamName = ""
    @State private var teamAdditionAlert = false
    
    var teamListSorted: [Team] {
        switch sorting {
            case .sequence:
                return currentState.getTeams()
            case .ranking:
                return currentState.getTeams().sorted(by: {
                    $0.overallPoints > $1.overallPoints
                })
        }
    }

    @State private var sorting = SortingMethod.sequence
    
    enum SortingMethod {
        case sequence
        case ranking
    }
    
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
            ScrollView {
                VStack {
                    ForEach($currentState.categories) { $category in
                        CategoryListing(category: $category)
                        Spacer(minLength: 20)
                    }
                }
                .padding()
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
                VStack {
                    Button("Show next category") {
                        showNextCategory()
                    }
                    .keyboardShortcut("#")
                    .disabled(!canCategoryBeShown())
                    Button("Show Master Question") {
                        openWindow(id: "mqst")
                    }
                    .disabled(!currentState.masterQuestionActivated)
                    .contextMenu {
                        if !currentState.masterQuestionActivated {
                            Button("Show anyways") {
                                openWindow(id: "mqst")
                            }
                        }
                    }
                }
                .padding()
                Spacer()
                VStack {
                    Text("Team List")
                    List {
                        ForEach(teamListSorted) { team in
                            let points = team.overallPoints
                            HStack {
                                Spacer()
                                Text("\(team.name) - \(points) Point(s)\n\(getTeamPosition(team: team)). Place - \(team.solvedQuestions.count) Answer(s)")
                                    .multilineTextAlignment(.center)
                                    .padding()
                                Spacer()
                            }
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke())
                            .padding(2)
                            .gesture(TapGesture().modifiers(.command).onEnded {
                                shownTeam = TeamListing(team: team, answers: team.solvedQuestions)
                            })
                            .contextMenu {
                                Button("Show Team") {
                                    shownTeam = TeamListing(team: team, answers: team.solvedQuestions)
                                }
                                Button("Delete", role: .destructive) {
                                    if team.solvedQuestions.count > 0 {
                                        teamToDelete = team
                                        teamDeletionAlertShown = true
                                    } else {
                                        currentState.deleteTeam(team: team)
                                    }
                                }
                            }
                        }
                        .onMove( perform: sorting == .sequence ? { from, to in
                            currentState.moveTeams(from: from, to: to)
                        } : nil)
                        .confirmationDialog("The Team has solved Questions", isPresented: $teamDeletionAlertShown) {
                            Button("Delete anyway", role: .destructive) {
                                guard let teamToDelete else {return}
                                
                                currentState.deleteTeam(team: teamToDelete)
                            }
                        }
                    }
                    .animation(.default, value: teamListSorted)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .popover(item: $shownTeam) { teamListing in
                        let team = teamListing.team
                        let answers = teamListing.answers
                        VStack {
                            Text("Solved Questions - \(team.name)")
                            ForEach(answers) { answer in
                                let question = answer.question
                                Text("\(answer.category) - \(answer.score)\n\(answer.correct ? "Correct" : "Wrong")")
                                    .fixedSize()
                                    .onTapGesture {
                                        openWindow(value: question)
                                    }
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke()
                                    }
                                    .padding()
                            }
                            
                            VStack {
                                Text("Added Points:")
                                if !teamPointsEditing {
                                    Text("\(team.addedPoints)")
                                        .onTapGesture {
                                            withAnimation {
                                                teamPointsEditing = true
                                            }
                                        }
                                } else {
                                    TextField("Added Points", value: $teamAddedPoints, format: .number)
                                        .onSubmit {
                                            withAnimation {
                                                teamPointsEditing = false
                                                team.addedPoints = teamAddedPoints
                                            }
                                        }
                                        .labelsHidden()
                                        .onAppear {
                                            teamAddedPoints = team.addedPoints
                                        }
                                    
                                }
                                
                            }
                            .padding()
                        }
                        .padding()
                    }
                }
                .overlay(alignment: .topLeading) {
                    Button {
                        addTeamSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.borderless)
                    .padding(2)
                    .sheet(isPresented: $addTeamSheet) {
                        VStack(spacing: 20) {
                            TextField("Team Name", text: $newTeamName)
                                .onSubmit {
                                    do {
                                        try currentState.addTeam(name: newTeamName)
                                    } catch {
                                        teamAdditionAlert = true
                                    }
                                    newTeamName = ""
                                    addTeamSheet = false
                                }
                            Button("Add") {
                                do {
                                    try currentState.addTeam(name: newTeamName)
                                } catch {
                                    teamAdditionAlert = true
                                }
                                newTeamName = ""
                                addTeamSheet = false
                            }
                        }
                        .padding()
                    }
                    .alert("This Name already exists!", isPresented: $teamAdditionAlert) {
                        Button("OK", role: .cancel) {
                            newTeamName = ""
                            addTeamSheet = false
                        }
                    }
                }
                .overlay(alignment: .topTrailing) {
                    Menu("\(sorting == .sequence ? "In Order" : "Ranking")") {
                        Picker("Sort", selection: $sorting) {
                            Text("In Order")
                                .tag(SortingMethod.sequence)
                            Text("Ranking")
                                .tag(SortingMethod.ranking)
                        }
                        .pickerStyle(.inline)
                        .labelsHidden()
                    }
                    .menuStyle(.borderlessButton)
                    .fixedSize()
                }
                Spacer()
            }
            .frame(width: 230)
        }
        .padding()
        .frame(width: 350 + 230)
    }

    func getTeamPosition(team: Team) -> Int {
        var position = 1
        for teamIterator in currentState.getTeams() {
            if teamIterator.overallPoints > team.overallPoints {
                position += 1
            }
        }
        if currentState.getTeams().contains(team) {
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
