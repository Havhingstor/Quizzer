import SwiftUI

@main
struct QuizzerApp: App {
    @StateObject private var currentState = CurrentState.examples
    
    var body: some Scene {
        Window("Quiz", id: "quiz") {
            QuizBoard()
                .environmentObject(currentState)
                .foregroundColor(.black)
        }
        .keyboardShortcut("q")
        
        Window("Control", id: "ctrl") {
            BoardControl()
                .environmentObject(currentState)
        }
        .windowResizability(.contentSize)
        .keyboardShortcut("c")
        
        Window("Question Presentation", id: "qst") {
            if currentState.showMasterQuestion {
                MasterQuestionControl(question: $currentState.masterQuestion)
                    .environmentObject(currentState)
            } else {
                let questionBinding = Binding<Question?>(get: {
                    currentState.currentQuestionResolved
                }, set: { newValue in
                    if let newQuestion = newValue {
                        currentState.currentQuestion = currentState.getIndexOfQuestion(newQuestion)
                    } else {
                        currentState.currentQuestion = nil
                    }
                })
                QuestionControl(question: questionBinding, isQL: false)
                    .environmentObject(currentState)
            }
        }
        .windowResizability(.contentSize)
        .keyboardShortcut("q", modifiers: [.shift, .command])
        
        WindowGroup("Question - QuickLook", for: Question.self) { q in
            QuestionControl(question: q, isQL: true)
                .environmentObject(currentState)
        }
        .windowResizability(.contentSize)
        
        Window("Result Control", id: "rslt") {
            EndControl()
                .environmentObject(currentState)
        }
        .windowResizability(.contentSize)
        .keyboardShortcut("r")
    }
}
