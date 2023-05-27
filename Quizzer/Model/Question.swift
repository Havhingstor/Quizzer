import Foundation

struct Question: Identifiable {
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
    
    var answered: Bool
    
    init(question: String, answer: String, category: String, weight: UInt8, answered: Bool) {
        self.question = question
        self.answer = answer
        self.category = category
        self.weight = weight
        self.answered = answered
    }
}
