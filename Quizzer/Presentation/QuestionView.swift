//
//  QuestionView.swift
//  Quizzer
//
//  Created by Paul on 27.05.23.
//

import SwiftUI

struct QuestionView: View {
    @EnvironmentObject var currentState: CurrentState
    
    @Binding var question: Question
    
    var pointsText: String {
        let number = Int(question.weight ) * currentState.baseScore
        
        let suffix: String
        if number == 1 || number == -1 {
            suffix = currentState.pointName
        } else {
            suffix = currentState.pointsName
        }
        
        return "\(number) \(suffix)"
    }
    
    var body: some View {
        VStack {
            Text("\(question.category) - \(pointsText)")
                .font(.custom("SF Pro", size: 60.0))
                .padding()
                .background(.gray.opacity(0.75))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
            
            Spacer()
            
            if currentState.questionStage > 0 {
                HStack {
                    Text("\(question.question)")
                        .font(.custom("SF Pro", size: 44.0))
                        .padding()
                        .background(.gray.opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding([.top,.trailing, .bottom])
                        .padding(.leading, 60)
                    Spacer()
                }
                Spacer()
                Spacer()
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct QuestionView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionView(question: .constant(Question(question: "What", answer: "That", category: "Test", weight: 1, answered: false)))
    }
}
