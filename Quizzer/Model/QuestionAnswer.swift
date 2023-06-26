import Foundation

struct QuestionAnswer {
    let _question: UUID
    let _team: String
    let answer: String
    let correct: Bool
    
    var team: Team {
        let currentState = CurrentState.shared
        if let team = currentState.getTeams().first(where: {$0.id == _team}) {
            return team
        } else {
            return Team(name: _team)
        }
    }
    
    var question: Question {
        get {
            let currentState = CurrentState.shared
            if let question = currentState.questions.first(where: {$0.id == _question}) {
                return question
            } else {
                return Question(question: "N/A", answer: "N/A", category: Category(name: "N/A"), weight: 0)
            }
        }
    }
    
    init(question: Question, team: Team, answer: String, correct: Bool) {
        self._question = question.id
        self._team = team.id
        self.answer = answer
        self.correct = correct
    }
}

struct QuestionExemption {
    let _question: UUID
    
    var question: Question {
        get {
            let currentState = CurrentState.shared
            if let question = currentState.questions.first(where: {$0.id == _question}) {
                return question
            } else {
                return Question(question: "N/A", answer: "N/A", category: Category(name: "N/A"), weight: 0)
            }
        }
    }
    
    init(question: Question) {
        self._question = question.id
    }
}
