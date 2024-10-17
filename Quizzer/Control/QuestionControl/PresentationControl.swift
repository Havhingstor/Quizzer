import SwiftUI

struct PresentationControls: View {
    @EnvironmentObject private var currentState: CurrentState
    
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
                    } else if stage >= 2 && !isJoker {
                        VStack {
                            Button("Hide Answer") {
                                withAnimation {
                                    currentState.questionStage = 1
                                }
                            }
                            .keyboardShortcut("-")
                        }
                    }
                    if !isJoker {
                        Button("Show pure Answer") {
                            withAnimation {
                                currentState.questionStage = 2
                            }
                        }
                        .hide(if: stage < 1 || stage == 2 )
                    }
                    Group {
                        if question?.solutionImage != nil {
                            if question?.solutionImage?.name != currentState.currentImage?.name {
                                Button("Show Solution Image") {
                                    withAnimation {
                                        currentState.currentImage = question?.solutionImage
                                    }
                                }
                                .hide(if: stage < 2 || question?.solutionImage == nil)
                            } else {
                                Button("Hide Solution Image") {
                                    withAnimation {
                                        currentState.currentImage = nil
                                    }
                                }
                                .hide(if: stage < 2)
                            }
                        } else {
                            Button(""){}
                                .hidden()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }
}
