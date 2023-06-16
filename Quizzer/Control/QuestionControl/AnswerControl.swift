import SwiftUI

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
