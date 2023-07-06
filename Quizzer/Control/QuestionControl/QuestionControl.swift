import AppKit
import SwiftUI

struct QuestionControl: View {
    @EnvironmentObject private var currentState: CurrentState
    @Environment(\.openWindow) private var openWindow

    @State private var answer = ""
    @State private var team = CurrentState.shared.nextTeam
    
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
            let givenAnswer = QuestionAnswer(question: question, team: team, answer: answer, correct: correct)
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
                HeaderView(question: $question, team: $team)

                QuestionAndAnswer(question: $question)

                PresentationControls(question: $question, isQL: isQL)

                Group {
                    AnswerControl(question: $question, isQL: isQL, answer: $answer, team: $team, goToControl: goToControl, registerAnswer: registerAnswer)

                    PreviousAnswerView(question: $question, isQL: isQL, answer: $answer, team: $team, goToControl: goToControl)
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
                        if currentState.currentImage != nil {
                            Button("Hide Solution Image") {
                                withAnimation {
                                    currentState.currentImage = nil
                                }
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
            .onAppear {
                if isQL,
                   let answer = question.givenAnswer {
                    team = answer.team
                } else {
                    team = currentState.nextTeam
                }
            }
        } else {
            Text("No Question")
                .padding()
                .frame(width: 250)
                .fixedSize()
        }
    }
}
