import Foundation
import SwiftUI

class CurrentState: ObservableObject {
    static var examples: CurrentState {
        shared.categories = [
            Category(name: "Allgemeinwissen", isShown: false),
            Category(name: "Religionen", isShown: false),
            Category(name: "Christentum", isShown: false),
            Category(name: "Geographie", isShown: false),
            Category(name: "Politik", isShown: false)
        ]
        shared.questions = [
            Question(question: "Q1", answer: "A1", category: "Allgemeinwissen", weight: 1),
            Question(question: "Q2", answer: "A2", category: "Allgemeinwissen", weight: 2),
            Question(question: "Q3", answer: "A3", category: "Allgemeinwissen", weight: 3),
            Question(question: "Q4", answer: "A4", category: "Allgemeinwissen", weight: 4),
            Question(question: "Q5", answer: "A5", category: "Religionen", weight: 1),
            Question(question: "Q6", answer: "A6", category: "Religionen", weight: 2),
            Question(question: "Q7", answer: "A7", category: "Religionen", weight: 3),
            Question(question: "Q8", answer: "A8", category: "Religionen", weight: 4),
            Question(question: "Q9", answer: "A9", category: "Christentum", weight: 1),
            Question(question: "Q10", answer: "A10", category: "Christentum", weight: 2),
            Question(question: "Q11", answer: "A11", category: "Christentum", weight: 3),
            Question(question: "Joker", answer: "A12", category: "Christentum", weight: 4),
            Question(question: "Q13", answer: "A13", category: "Geographie", weight: 1),
            Question(question: "Q14", answer: "A14", category: "Geographie", weight: 2),
            Question(question: "Q15", answer: "A15", category: "Geographie", weight: 3),
            Question(question: "Q16", answer: "A16", category: "Geographie", weight: 4),
            Question(question: "Q17", answer: "A17", category: "Politik", weight: 1),
            Question(question: "Q18", answer: "A18", category: "Politik", weight: 2),
            Question(question: "Q19", answer: "A19", category: "Politik", weight: 3),
            Question(question: "Q17", answer: "A20", category: "Politik", weight: 4),
        ]
        shared.teams = [
            Team(name: "Team A"),
            Team(name: "Team B"),
            Team(name: "Team C"),
            Team(name: "Team D")
        ]
        shared.masterQuestion = MasterQuestion(question: "Wie weit?", answerInternal: 100)
        return shared
    }
    
    private init() {}
    
    
    static let shared = CurrentState()
    
    @Published var categories = [Category]() {
        didSet {
            isInStartStage = categories.filter { $0.isShown }.count == 0
        }
    }
    
    @Published var questions = [Question]()
    @Published var masterQuestion: MasterQuestion?
    
    var masterQuestionActivated: Bool {
        for question in questions {
            if !question.answered {
                return false
            }
        }
        
        return masterQuestion != nil
    }
    
    @Published var showMasterQuestion = false
    
    @Published var currentQuestion: Binding<Question>? = nil {
        didSet {
            if let currentQuestion {
                if let stage = questionStages[currentQuestion.id] {
                    questionStage = stage
                } else {
                    questionStage = 0
                }
            }
        }
    }
    @Published var questionStage = 0 {
        didSet {
            if let currentQuestion {
                questionStages[currentQuestion.id] = questionStage
            }
        }
    }
    
    @Published var questionStages = [String: Int]()
    
    @Published var questionsAnswered = [QuestionAnswer]()
    @Published var questionsExempt = [QuestionExemption]()
    
    @Published var isInStartStage = false
    
    
    @Published var baseScore = 25
    @Published var introTitle = "Konfifreizeit Quiz\n2023"
    
    @Published var pointsName = "Punkte"
    @Published var pointName = "Punkt"
    
    @Published var placeName = "Platz"
    @Published var answersName = "Antworten"
    
    @Published var questionName = "Frage"
    @Published var masterQuestionName = "Masterfrage"
    @Published var answerName = "Antwort"
    
    @Published private var teams = [Team]() {
        didSet {
            fixNextTeam()
        }
    }
    
    func moveTeams(from: IndexSet, to: Int) {
        if teams.count > 0 {
            teams.move(fromOffsets: from, toOffset: to)
        }
    }
    
    func deleteTeam(team: Team) {
        if teams.count > 0,
           let index = teams.firstIndex(of: team) {
            questionsAnswered.removeAll {
                $0.team == team
            }
            teams.remove(at: index)
        }
    }
    
    func getTeams() -> [Team] {
        if teams.count > 0 {
            return teams
        } else {
            return [Team(name: "Default Team")]
        }
    }
    
    func addTeam(name: String) throws {
        if teams.contains(where: {$0.name == name}) {
            throw QuizError.teamNameAlreadyExists
        }
        teams.append(Team(name: name))
    }
    
    enum QuizError: Error {
        case teamNameAlreadyExists
    }
    
    @Published private var nextTeamOp: Team? = nil
    
    var nextTeam: Team {
        get {
            if let nextTeamOp  {
                return nextTeamOp
            } else {
                return Team(name: "Default Team")
            }
        }
        set {
            nextTeamOp = newValue
        }
    }
    
    private func fixNextTeam() {
        if !getTeams().contains(nextTeam),
           let first = teams.first {
            nextTeam = first
        }
    }
    
    func progressTeam() {
        if let index = getTeams().firstIndex(of: nextTeam) {
            self.nextTeam = teams[(index + 1) % teams.count]
        } else {
            fixNextTeam()
        }
    }
}
