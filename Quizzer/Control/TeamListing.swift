import Foundation

struct TeamListing: Identifiable {
    let team: Team
    let answers: [AnswerListing]
    let id = UUID()
    
    init(team: Team, answers: [QuestionAnswer]) {
        self.team = team
        let currentState = CurrentState.shared
        let baseScore = currentState.baseScore
        self.answers = answers.map { answer in
            AnswerListing(question: answer.question, correct: answer.correct, score: answer.question.weight * baseScore, category: answer.question.category)
        }
    }
}

struct AnswerListing: Identifiable {
    let question: Question
    let correct: Bool
    let score: UInt
    let category: String
    let id = UUID()
}
