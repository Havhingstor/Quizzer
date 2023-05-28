import Foundation

class Team: Identifiable, Hashable {
    static func == (lhs: Team, rhs: Team) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    var name: String
    var id: String {name}
    var currentState = CurrentState.shared
    
    var solvedQuestions: [QuestionAnswer] {
        currentState.questionsAnswered.filter({$0.team === self})
    }
    var addedPoints = 0
    var overallPoints: Int {
        var result = addedPoints
        for question in solvedQuestions {
            result += Int(question.question.weight) * currentState.baseScore
        }
        return result
    }
    
    init(name: String) {
        self.name = name
    }
}
