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
    var currentState: CurrentState
    
    var solvedQuestions = [Question]()
    var addedPoints = 0
    var overallPoints: Int {
        var result = addedPoints
        for question in solvedQuestions {
            result += Int(question.weight) * currentState.baseScore
        }
        return result
    }
    
    init(name: String, currentState: CurrentState) {
        self.name = name
        self.currentState = currentState
    }
}
