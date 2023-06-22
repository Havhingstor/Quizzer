import Foundation
import OSLog

class Team: Identifiable, Hashable, ObservableObject {
    static func == (lhs: Team, rhs: Team) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    @Published var name: String
    var id: String {name}
    var currentState = CurrentState.shared
    
    var solvedQuestions: [QuestionAnswer] {
        currentState.questionsAnswered.filter({$0.team === self})
    }
    @Published var addedPoints = 0
    var overallPoints: UInt {
        var result = addedPoints
        for question in solvedQuestions {
            if question.correct {
                result += Int(question.question.weight * currentState.baseScore)
            }
        }
        if result < 0 {
            return 0
        } else {
            return UInt(result)
        }
    }
    
    init(name: String) {
        self.name = name
    }
    
    @Published var betPts:  UInt? = nil {
        didSet {
            betPtsControl(old: oldValue)
        }
    }
    
    private func betPtsControl(old: UInt? = nil) {
        if let betPts,
           betPts > overallPoints {
            if let old {
                if old > overallPoints {
                    self.betPts = 0
                } else {
                    self.betPts = old
                }
            } else {
                self.betPts = 0
            }
        }
    }
    
    @Published var masterQstAnswer = 0
    
    var endPoints: UInt {
        if let masterQst = currentState.masterQuestion {
            betPtsControl()
            if masterQst.answerInternal == masterQstAnswer {
                return overallPoints + (betPts ?? 0)
            } else {
                return overallPoints - (betPts ?? 0)
            }
        } else {
            return overallPoints
        }
    }
}
