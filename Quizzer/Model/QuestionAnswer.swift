import Foundation

struct QuestionAnswer {
    let _question: String
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
        let currentState = CurrentState.shared
        if let question = currentState.questions.first(where: {$0.id == _question}) {
            return question
        } else {
            return Question(question: "", answer: "", category: "", weight: 0)
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
    let _question: String
    
    var question: Question {
        let currentState = CurrentState.shared
        if let question = currentState.questions.first(where: {$0.id == _question}) {
            return question
        } else {
            return Question(question: "", answer: "", category: "", weight: 0)
        }
    }
    
    init(question: Question) {
        self._question = question.id
    }
}
