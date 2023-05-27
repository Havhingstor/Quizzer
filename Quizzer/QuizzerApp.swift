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
        Window("Control", id: "ctrl") {
            BoardControl()
                .environmentObject(currentState)
        }
        Window("Question", id: "qst") {
            QuestionControl()
                .environmentObject(currentState)
        }
    }
}
