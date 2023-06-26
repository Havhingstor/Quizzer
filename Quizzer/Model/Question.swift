import Foundation

struct Question: Identifiable, Codable, Hashable {
    static func == (lhs: Question, rhs: Question) -> Bool {
        lhs.id == rhs.id
    }
    
    var question: String
    var answer: String
    private (set) var id = UUID()
    
    var category: UUID
    var weight: UInt
    var image: NamedData?
    var solutionImage: NamedData?
    
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
    
    var categoryObject: Category? {
        CurrentState.shared.categories.first { category in
            category.id == self.category
        }
    }
    
    init(question: String, answer: String, category: Category, weight: UInt, image: NamedData? = nil, solutionImage: NamedData? = nil) {
        self.question = question
        self.answer = answer
        self.category = category.id
        self.weight = weight
        self.image = image
        self.solutionImage = solutionImage
    }
}
