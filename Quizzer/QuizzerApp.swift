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
        .keyboardShortcut("q", modifiers: [])
        
        Window("Control", id: "ctrl") {
            BoardControl()
                .environmentObject(currentState)
        }
        .windowResizability(.contentSize)
        .keyboardShortcut("c", modifiers: [])
        
        Window("Question Presentation", id: "qst") {
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
        .windowResizability(.contentSize)
        .keyboardShortcut("q", modifiers: .shift)
        
        WindowGroup("Question - QuickLook", for: Question.self) { q in
            QuestionControl(question: q, isQL: false)
                .environmentObject(currentState)
        }
        .windowResizability(.contentSize)
        
        WindowGroup("Master Question", id: "mqst") {
            MasterQuestionControl(question: $currentState.masterQuestion)
                .environmentObject(currentState)
        }
        .windowResizability(.contentSize)
    }
}
