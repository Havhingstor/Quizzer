import Foundation

class Team: Identifiable, Hashable, ObservableObject, Codable {
    static func == (lhs: Team, rhs: Team) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    @Published var name: String
    var id: String {name}
    var currentState: CurrentState {
        CurrentState.shared
    }
    
    var solvedQuestions: [QuestionAnswer] {
        currentState.questionsAnswered.filter({$0.team === self})
    }
    @Published var addedPoints = 0
    var overallPoints: UInt {
        var result = addedPoints
        for question in solvedQuestions {
            if question.correct {
                result += Int(question.question.weight * currentState.storageContainer.baseScore)
            }
        }
        if result < 0 {
            result = 0
        }
        
        let uResult = UInt(result)
        
        if currentState.showResults {
            return generateEndPoints(overallBefore: uResult)
        } else {
            return uResult
        }
    }
    
    init(name: String) {
        self.name = name
    }
    
    @Published var betPts:  UInt? = nil {
        didSet {
            betPtsControl(old: oldValue, overallPoints: overallPoints)
            currentState.betUpdate()
        }
    }
    
    private func betPtsControl(old: UInt? = nil, overallPoints: UInt) {
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
    
    private func generateEndPoints(overallBefore: UInt) -> UInt {
        if let masterQst = currentState.masterQuestion {
            betPtsControl(overallPoints: overallBefore)
            if masterQst.answerInternal == masterQstAnswer {
                return overallBefore + (betPts ?? 0)
            } else {
                return overallBefore - (betPts ?? 0)
            }
        } else {
            return overallBefore
        }
    }
    
    enum CodingKeys: CodingKey {
        case name
        case addedPoints
        case betPts
        case masterQstAnswer
    }
    
    required init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        addedPoints = try container.decode(Int.self, forKey: .addedPoints)
        betPts = try container.decode(UInt?.self, forKey: .betPts)
        masterQstAnswer = try container.decode(Int.self, forKey: .masterQstAnswer)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(addedPoints, forKey: .addedPoints)
        try container.encode(betPts, forKey: .betPts)
        try container.encode(masterQstAnswer, forKey: .masterQstAnswer)
    }
}
