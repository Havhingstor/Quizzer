import Foundation
import SwiftUI

class CurrentState: ObservableObject {
    static var examples: CurrentState {
        let result = CurrentState()
        result.categories = [
            Category(name: "Allgemeinwissen", isShown: false),
            Category(name: "Religionen", isShown: false),
            Category(name: "Christentum", isShown: false),
            Category(name: "Geographie", isShown: false),
            Category(name: "Politik", isShown: false)
        ]
        result.questions = [
            Question(question: "Q1", answer: "A1", category: "Allgemeinwissen", weight: 1, answered: false),
            Question(question: "Q2", answer: "A2", category: "Allgemeinwissen", weight: 2, answered: false),
            Question(question: "Q3", answer: "A3", category: "Allgemeinwissen", weight: 3, answered: false),
            Question(question: "Q4", answer: "A4", category: "Allgemeinwissen", weight: 4, answered: false),
            Question(question: "Q5", answer: "A5", category: "Religionen", weight: 1, answered: false),
            Question(question: "Q6", answer: "A6", category: "Religionen", weight: 2, answered: false),
            Question(question: "Q7", answer: "A7", category: "Religionen", weight: 3, answered: false),
            Question(question: "Q8", answer: "A8", category: "Religionen", weight: 4, answered: false),
            Question(question: "Q9", answer: "A9", category: "Christentum", weight: 1, answered: false),
            Question(question: "Q10", answer: "A10", category: "Christentum", weight: 2, answered: false),
            Question(question: "Q11", answer: "A11", category: "Christentum", weight: 3, answered: false),
            Question(question: "Q12", answer: "A12", category: "Christentum", weight: 4, answered: false),
            Question(question: "Q13", answer: "A13", category: "Geographie", weight: 1, answered: false),
            Question(question: "Q14", answer: "A14", category: "Geographie", weight: 2, answered: false),
            Question(question: "Q15", answer: "A15", category: "Geographie", weight: 3, answered: false),
            Question(question: "Q16", answer: "A16", category: "Geographie", weight: 4, answered: false),
            Question(question: "Q17", answer: "A17", category: "Politik", weight: 1, answered: false),
            Question(question: "Q18", answer: "A18", category: "Politik", weight: 2, answered: false),
            Question(question: "Q19", answer: "A19", category: "Politik", weight: 3, answered: false),
            Question(question: "Q17", answer: "A20", category: "Politik", weight: 4, answered: false),
        ]
        return result
    }
    
    @Published var categories = [Category]() {
        didSet {
            isInStartStage = categories.filter { $0.isShown }.count == 0
        }
    }
    
    @Published var questions = [Question]()
    
    @Published var currentQuestion: Binding<Question>? = nil
    @Published var isInStartStage = false
    
    
    @Published var baseScore = 25
    @Published var introTitle = "Konfifreizeit Quiz\n2023"
    
    @Published var pointsName = "Punkte"
    @Published var pointName = "Punkt"
}
