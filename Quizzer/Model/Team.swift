import Foundation

class Team: Identifiable {
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
