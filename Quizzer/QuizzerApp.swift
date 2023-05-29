import SwiftUI

@main
struct QuizzerApp: App {
    @StateObject var currentState = CurrentState.examples
    
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
            QuestionControl(selectedQuestion: nil)
                .environmentObject(currentState)
        }
        .windowResizability(.contentSize)
        .keyboardShortcut("q", modifiers: .shift)
        
        WindowGroup("Question - QuickLook", for: Question.self) { $q in
            QuestionControl(selectedQuestion: $q)
                .environmentObject(currentState)
        }
        .windowResizability(.contentSize)
    }
}
