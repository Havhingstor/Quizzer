import Foundation

protocol QuestionViewProperties {
    var question: String {get}
    var answer: String {get}
    var image: String? {get}
    var solutionImage: String? {get}
}

struct Question: Identifiable, Codable, Hashable, QuestionViewProperties {
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
    let image: String?
    let solutionImage: String?
    
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
    
    init(question: String, answer: String, category: String, weight: UInt8, image: String? = nil, solutionImage: String? = nil) {
        self.question = question
        self.answer = answer
        self.category = category
        self.weight = weight
        self.image = image
        self.solutionImage = solutionImage
    }
}
