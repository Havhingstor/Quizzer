import AppKit
import SwiftUI

struct QuestionControl: View {
    @EnvironmentObject var currentState: CurrentState
    @Environment(\.openWindow) var openWindow

    @State private var answer = ""
    @State private var teamInternal = CurrentState.shared.getTeams().first!
    var team: Binding<Team> {
        if isQL {
            return $teamInternal
        } else {
            return $currentState.nextTeam
        }
    }
    
    @Binding var question: Question?
    
    var isQL: Bool

    func goToControl() {
        if !isQL {
            openWindow(id: "ctrl")
        }
        if currentState.currentQuestionResolved == question {
            withAnimation {
                currentState.currentQuestion = nil
                currentState.currentImage = nil
            }
        }
    }

    var isJoker: Bool {
        question?.question.lowercased() == "joker"
    }

    func setAnswer(_ givenAnswer: QuestionAnswer) {
        question?.givenAnswer = givenAnswer
    }
    
    func registerAnswer(_ correct: Bool) {
        if let question {
            let givenAnswer = QuestionAnswer(question: question, team: team.wrappedValue, answer: answer, correct: correct)
            if !question.answered {
                withAnimation {
                    setAnswer(givenAnswer)
                }
            } else {
                setAnswer(givenAnswer)
            }
            if !isQL {
                withAnimation {
                    currentState.progressTeam()
                }
            }
            goToControl()
        }
    }

    var body: some View {
        if let question {
            VStack(alignment: .center) {
                HeaderView(question: $question, team: team)

                QuestionAndAnswer(question: $question)

                PresentationControls(question: $question, isQL: isQL)

                Group {
                    AnswerControl(question: $question, isQL: isQL, answer: $answer, team: team, goToControl: goToControl, registerAnswer: registerAnswer)

                    PreviousAnswer(question: $question, isQL: isQL, answer: $answer, teamInternal: $teamInternal, goToControl: goToControl)
                }
                .hide(if: question.exempt)

                ExemptView(question: $question, isQL: isQL)
            }
            .padding()
            .frame(minWidth: 350)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        if currentState.questionStage >= 2 {
                            Button("Hide Answer and Question ") {
                                withAnimation {
                                    currentState.questionStage = 0
                                }
                            }
                            .keyboardShortcut("-", modifiers: [.shift, .command])
                        }
                        if currentState.questionStage > 2 {
                            let correct = currentState.questionStage == 3
                            Button("Show Answer as \(correct ? "wrong" : "correct")") {
                                withAnimation {
                                    currentState.questionStage = correct ? 4 : 3
                                }
                            }
                            Button("Register \(!correct ? "correct" : "wrong") answer") {
                                registerAnswer(!correct)
                            }
                        } else {
                            Button("Register correct Answer") {
                                registerAnswer(true)
                            }
                            Button("Register wrong Answer") {
                                registerAnswer(false)
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .menuStyle(.borderlessButton)
                    .menuIndicator(.hidden)
                }
            }
            .fixedSize()
        } else {
            Text("No Question")
                .padding()
                .frame(width: 250)
                .fixedSize()
        }
    }
}

struct HeaderView: View {
    @EnvironmentObject var currentState: CurrentState

    @Binding var question: Question?
    @Binding var team: Team

    var categoryAndPoints: String {
        if let question {
            return "\(question.category) - \(Int(question.weight) * currentState.baseScore)"
        } else {
            return ""
        }
    }

    var body: some View {
        if question != nil {
            Text(categoryAndPoints)
                .font(.largeTitle)
                .padding()

            VStack {
                Text("Team")
                Picker("Team", selection: $team) {
                    ForEach(currentState.getTeams()) { team in
                        Text("\(team.name)").tag(team)
                    }
                }
                .labelsHidden()
            }
            .padding()
        }
    }
}

struct QuestionAndAnswer: View {
    @Binding var question: Question?

    var isJoker: Bool {
        question?.question.lowercased() == "joker"
    }

    var body: some View {
        if let question {
            if !isJoker {
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
                        Text(question.answer)
                            .font(.headline)
                            .italic()
                    }
                } label: {
                    Text("Question &\nTrue Answer")
                        .multilineTextAlignment(.center)
                        .font(.title2)
                }
                .padding()
            } else {
                Text("Joker")
                    .font(.title)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
}

struct PresentationControls: View {
    @EnvironmentObject var currentState: CurrentState

    @Binding var question: Question?
    var isQL: Bool

    var isJoker: Bool {
        question?.question.lowercased() == "joker"
    }

    var body: some View {
        if !isQL && question != nil {
            Group {
                let stage = currentState.questionStage
                VStack {
                    if stage == 0 {
                        Button("Show Question") {
                            withAnimation {
                                currentState.questionStage = 1
                            }
                        }
                        .keyboardShortcut("#")
                    } else if stage == 1 {
                        Button("Hide Question") {
                            withAnimation {
                                currentState.questionStage = 0
                            }
                        }
                        .keyboardShortcut("-")
                    } else if stage >= 2 {
                        VStack {
                            Button("Hide Answer") {
                                withAnimation {
                                    currentState.questionStage = 1
                                }
                            }
                            .keyboardShortcut("-")
                        }
                    }
                    Button("Show pure Answer") {
                        withAnimation {
                            currentState.questionStage = 2
                        }
                    }
                    .hide(if: stage < 1 || stage == 2)
                }
            }
            .padding()
        }
    }
}

struct AnswerControl: View {
    @EnvironmentObject var currentState: CurrentState

    @Binding var question: Question?
    var isQL: Bool

    @Binding var answer: String
    @Binding var team: Team

    var goToControl: () -> Void
    var registerAnswer: (Bool) -> Void

    var isJoker: Bool {
        question?.question.lowercased() == "joker"
    }

    func executeTransitionForRegister(givenAnswer _: QuestionAnswer) {
        if !isQL {}
    }

    var body: some View {
        if question != nil {
            if !isJoker {
                GroupBox {
                    TextField(text: $answer) {
                        Text("Given Answer")
                    }
                    if !isQL {
                        if currentState.questionStage < 3 {
                            Button("Show Answer as correct") {
                                withAnimation {
                                    currentState.questionStage = 3
                                }
                            }
                            .disabled(currentState.questionStage < 1)

                            Button("Show Answer as wrong") {
                                withAnimation {
                                    currentState.questionStage = 4
                                }
                            }
                            .disabled(currentState.questionStage < 1)
                        } else {
                            let correct = currentState.questionStage == 3
                            Button("Register \(correct ? "correct" : "wrong") answer") {
                                registerAnswer(correct)
                            }
                            Group {
                                if currentState.currentImage == question?.solutionImage {
                                    Button("Hide solution image") {
                                        withAnimation {
                                            currentState.currentImage = nil
                                        }
                                    }
                                } else {
                                    Button("Show solution image") {
                                        withAnimation {
                                            currentState.currentImage = question?.solutionImage
                                        }
                                    }
                                }
                            }
                            .hide(if: question?.solutionImage == nil)
                        }
                    } else {
                        Button("Register correct answer") {
                            registerAnswer(true)
                        }

                        Button("Register wrong answer") {
                            registerAnswer(false)
                        }
                    }
                    if !isQL {
                        Button("Cancel") {
                            goToControl()
                        }
                    }
                } label: {
                    Text("Given Answer")
                        .font(.title2)
                }
            } else {
                Button("Claim") {
                    registerAnswer(true)
                }
                .padding()
            }
        }
    }
}

struct PreviousAnswer: View {
    @EnvironmentObject var currentState: CurrentState

    @Binding var question: Question?
    var isQL: Bool

    @Binding var answer: String
    @Binding var teamInternal: Team

    var goToControl: () -> Void

    var isJoker: Bool {
        question?.question.lowercased() == "joker"
    }

    func deleteAnswer() {
        if var question {
            question.givenAnswer = nil
        }
    }

    var body: some View {
        if let questionAnswer = question?.givenAnswer {
            GroupBox {
                VStack {
                    Text("Previous Team")
                    Text("\(questionAnswer.team.name)")
                        .font(.headline)
                }
                .padding([.leading, .trailing])
                .onAppear {
                    if let oldTeam = question?.givenAnswer?.team {
                        teamInternal = oldTeam
                    }
                }

                if !isJoker {
                    VStack {
                        Text("Previous Answer")
                        let prevAnswer = questionAnswer.answer
                        let pACount = prevAnswer.count
                        Text("\(pACount > 0 ? prevAnswer : "- / -")")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .italic()
                        Text("\(questionAnswer.correct ? "Correct" : "Wrong")")
                    }
                    .padding()
                    .onAppear {
                        answer = questionAnswer.answer
                    }

                    Button("Remove Answer") {
                        deleteAnswer()
                        goToControl()
                    }
                }
            } label: {
                Text("Previous Answer")
                    .font(.title2)
            }
            .padding()
        } else if isQL {
            Text("Not Answered")
                .padding()
        }
    }
}

struct ExemptView: View {
    @EnvironmentObject var currentState: CurrentState

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
