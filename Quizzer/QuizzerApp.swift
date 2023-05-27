//
//  QuizzerApp.swift
//  Quizzer
//
//  Created by Paul on 27.05.23.
//

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
        Window("Question", id: "qst") {
            QuestionControl()
                .environmentObject(currentState)
        }
        .windowResizability(.contentSize)
        WindowGroup(for: Question.self) { q in
            if let _ = q.wrappedValue {
                QuestionQuicklook(question: q)
                    .environmentObject(currentState)
            }
        }
        .commandsRemoved()
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
