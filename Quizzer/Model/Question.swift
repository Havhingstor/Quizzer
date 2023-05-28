import Foundation

struct Question: Identifiable, Codable, Hashable {
    static func == (lhs: Question, rhs: Question) -> Bool {
        lhs.id == rhs.id
    }
    
    let question: String
    let answer: String
    var id: String {
        "\(category) \(weight)"
    }
    
    let category: String
    let weight: UInt8
    
    var answered: Bool {
        givenAnswer != nil
    }
    
    var exempt: Bool {
        get {
            CurrentState.shared.questionsExempt.contains(where: {$0.question == self})
        }
        set {
            givenAnswer = nil
            if newValue != exempt {
                let currentState = CurrentState.shared
                if newValue {
                    currentState.questionsExempt.append(QuestionExemption(question: self))
                } else {
                    currentState.questionsExempt.removeAll(where: {$0.question == self})
                }
            }
        }
    }
    
    var shouldOpen: Bool {
        !answered && !exempt
    }
    
    var givenAnswer: QuestionAnswer? {
        get {
            let currentState = CurrentState.shared
            return currentState.questionsAnswered.first(where: {$0.question == self})
        }
        set {
            let currentState = CurrentState.shared
            currentState.questionsAnswered.removeAll(where: {$0.question == self})
            if let newValue {
                currentState.questionsAnswered.append(newValue)
            }
        }
    }
    
    init(question: String, answer: String, category: String, weight: UInt8) {
        self.question = question
        self.answer = answer
        self.category = category
        self.weight = weight
    }
}
