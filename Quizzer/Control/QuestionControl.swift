import AppKit
import SwiftUI

struct QuestionControl: View {
    @EnvironmentObject var currentState: CurrentState
    @Environment(\.openWindow) var openWindow

    @State var answer = ""
    @State var teamInternal = CurrentState.shared.teams.first!
    var team: Binding<Team> {
        if questionSelected {
            return $teamInternal
        } else {
            return $currentState.nextTeam
        }
    }

    var selectedQuestion: Binding<Question?>?

    var categoryAndPoints: String {
        if let usedQuestion {
            return "\(usedQuestion.category) - \(Int(usedQuestion.weight) * currentState.baseScore)"
        } else {
            return ""
        }
    }

    var isJoker: Bool {
        usedQuestion?.question.lowercased() == "joker"
    }

    func goToControl() {
        if !questionSelected {
            openWindow(id: "ctrl")
        }
    }
    
    func registerOnly(givenAnswer: QuestionAnswer) {
        if !questionSelected {
            currentState.currentQuestion?.wrappedValue.givenAnswer = givenAnswer
            currentState.currentQuestion = nil
        } else {
            selectedQuestion?.wrappedValue?.givenAnswer = givenAnswer
        }
    }

    func registerAnswer(correct: Bool) {
        if let question = usedQuestion {
            let givenAnswer = QuestionAnswer(question: question, team: team.wrappedValue, answer: answer, correct: correct)
            if !question.answered {
                withAnimation {
                    registerOnly(givenAnswer: givenAnswer)
                }
            } else {
                registerOnly(givenAnswer: givenAnswer)
            }
            goToControl()
            if !questionSelected {
                withAnimation {
                    currentState.progressTeam()
                }
            }
        }
    }

    func deleteAnswer() {
        if let questionWrapper = selectedQuestion,
           var question = questionWrapper.wrappedValue
        {
            withAnimation {
                question.givenAnswer = nil
            }
//            dismiss()
        goToControl()
        }
    }

    var usedQuestion: Question? {
        return selectedQuestion?.wrappedValue ?? currentState.currentQuestion?.wrappedValue
    }

    var questionSelected: Bool {
        selectedQuestion?.wrappedValue != nil
    }

    var body: some View {
        if let question = usedQuestion {
            VStack(alignment: .center) {
                Text(categoryAndPoints)
                    .font(.largeTitle)
                    .padding()

                VStack {
                    Text("Team")
                    Picker("Team", selection: team) {
                        ForEach(currentState.getTeams()) { team in
                            Text("\(team.name)").tag(team)
                        }
                    }
                    .labelsHidden()
                }
                .padding()

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

                if !question.exempt || questionSelected {
                    Group {
                        if !questionSelected {
                            GroupBox {
                                HStack {
                                    Button("Previous") {
                                        withAnimation {
                                            currentState.questionStage -= 1
                                            currentState.questionStage = max(currentState.questionStage, 0)
                                        }
                                    }
                                    .fixedSize()
                                    .keyboardShortcut("-")
                                    .disabled(currentState.questionStage <= 0)
                                    let maxVal = isJoker ? 1 : 2
                                    Button("Next") {
                                        withAnimation {
                                            currentState.questionStage += 1
                                            currentState.questionStage = min(currentState.questionStage, maxVal)
                                        }
                                    }
                                    .keyboardShortcut("#")
                                    .disabled(currentState.questionStage >= maxVal)

                                    Text("Stage \(currentState.questionStage) / \(maxVal)")
                                }
                            } label: {
                                Text("Presentation")
                                    .font(.title2)
                            }
                            .padding()
                        }

                        if !isJoker {
                            GroupBox {
                                TextField(text: $answer) {
                                    Text("Given Answer")
                                }
                                Button("Register correct answer") {
                                    registerAnswer(correct: true)
                                }
                                Button("Register wrong answer") {
                                    registerAnswer(correct: false)
                                }
                                if !questionSelected {
                                    Button("Cancel") {
                                        withAnimation {
                                            currentState.currentQuestion = nil
                                        }
                                        goToControl()
                                    }
                                }
                            } label: {
                                Text("Given Answer")
                                    .font(.title2)
                            }
                        } else {
                            Button("Claim") {
                                registerAnswer(correct: true)
                            }
                            .padding()
                        }

                        if questionSelected,
                           let questionAnswer = usedQuestion?.givenAnswer
                        {
                            GroupBox {
                                VStack {
                                    Text("Previous Team")
                                    Text("\(questionAnswer.team.name)")
                                        .font(.headline)
                                }
                                .padding([.leading, .trailing])
                                .onAppear {
                                    if let oldTeam = selectedQuestion?.wrappedValue?.givenAnswer?.team {
                                        teamInternal = oldTeam
                                    }
                                }
                                if !isJoker {
                                    VStack {
                                        Text("Previous Answer")
                                        let prevAnswer = questionAnswer.answer
                                        let pACount = prevAnswer.count
                                        Text("\(pACount > 0 ? prevAnswer : "/")")
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
                                    }
                                }
                            } label: {
                                Text("Previous Answer")
                                    .font(.title2)
                            }
                            .padding()
                        } else if questionSelected {
                            Text("Not Answered")
                                .padding()
                        }
                    }
                    .hide(if: question.exempt)
                }

                if questionSelected {
                    Button("Mark as \(question.exempt ? "Not " : "")Exempt") {
                        withAnimation {
                            selectedQuestion?.wrappedValue?.exempt.toggle()
                        }
                    }
                    .animation(.none, value: question.exempt)
                    .padding()
                }
            }
            .padding()
            .fixedSize()
        } else {
            Text("No Question")
                .padding()
                .frame(width: 250)
                .fixedSize()
        }
    }
}
