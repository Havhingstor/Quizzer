//
//  QuestionQuicklook.swift
//  Quizzer
//
//  Created by Paul on 27.05.23.
//

import SwiftUI

struct QuestionQuicklook: View {
    @Binding var question: Question?
    @EnvironmentObject var currentState: CurrentState
    
    var body: some View {
        if let question {
            VStack {
                Text("\(question.category) - \(Int(question.weight) * currentState.baseScore)")
                Text("\(question.question)")
                Capsule()
                    .frame(height: 2)
                Text("\(question.answer)")
            }
            .multilineTextAlignment(.center)
            .padding()
            .fixedSize()
        }
    }
}

public var openingQL = false
