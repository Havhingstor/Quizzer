import Foundation
import SwiftUI

class CurrentState: ObservableObject {
    static var examples: CurrentState {
        shared.categories = [
            Category(name: "Allgemeinwissen"),
            Category(name: "Religionen"),
            Category(name: "Christentum"),
            Category(name: "Geographie"),
            Category(name: "Politik")
        ]
        shared.questions = [
            Question(question: "Q1", answer: "A1", category: "Allgemeinwissen", weight: 1, image: "HRR", solutionImage: "Kaiser"),
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
        shared.masterQuestion = MasterQuestion(question: "Welche?", answerInternal: 2, optionsInternal: ["1","2","3","4"], image: "Kaiser", solutionImage: "HRR")
        
        shared.images["HRR"] = NSImage(named: "HRR")!.cgImage(forProposedRect: nil, context: nil, hints: nil)
        shared.images["Kaiser"] = NSImage(named: "Kaiser")!.cgImage(forProposedRect: nil, context: nil, hints: nil)
        
        for (index, team) in shared.teams.enumerated() {
            team.addedPoints = index
        }
        return shared
    }
    
    private init() {}
    
    
    static let shared = CurrentState()
    
    @Published var categories = [Category]() {
        didSet {
            isInStartStage = categories.filter { $0.isShown }.count == 0
        }
    }
    
    func addCategory(name: String) throws {
        for category in categories {
            if category.name == name {
                throw QuizError.categoryNameAlreadyExists
            }
        }
        
        categories.append(Category(name: name))
    }
    
    func moveCategory(from: IndexSet, to: Int) {
        if categories.count > 0 {
            categories.move(fromOffsets: from, toOffset: to)
        }
    }
    
    func deleteCategory(_ category: Category) {
        questions.filter { question in
            question.category == category.name
        }.forEach { question in
            deleteQuestion(question)
        }
        
        categories.removeAll { item in
            item.id == category.id
        }
    }
    
    @Published var questions = [Question]()
    @Published var masterQuestion: MasterQuestion?
    @Published var images = [String: CGImage]()
    
    public func addQuestion(question: Question) throws {
        for questionItem in questions {
            if questionItem.category == question.category,
               questionItem.weight == question.weight {
                throw QuizError.questionWeightAlreadyExistsInCategory
            }
        }
        
        questions.append(question)
    }
    
    public func deleteQuestion(_ question: Question) {
        questionsAnswered.removeAll { answer in
            answer.question.id == question.id
        }
        
        questionsExempt.removeAll { exemption in
            exemption.question.id == question.id
        }
        
        questions.removeAll { item in
            item.id == question.id
        }
    }
    
    var masterQuestionActivated: Bool {
        for question in questions {
            if !question.answered {
                return false
            }
        }
        
        return masterQuestion != nil
    }
    
    @Published var showMasterQuestion = false {
        didSet {
            if showMasterQuestion {
                if let stage = questionStages["master"] {
                    questionStage = stage
                } else {
                    questionStage = 0
                }
            }
        }
    }
    @Published var showResults = false
    
    @Published var resultsStage = 0
    
    @Published var currentQuestion: Int? = nil {
        didSet {
            if let question = currentQuestionResolved {
                if let stage = questionStages[question.id] {
                    questionStage = stage
                } else {
                    questionStage = 0
                }
            }
        }
    }
    
    @Published var currentImage: String? = nil
    
    func getIndexOfQuestion(_ question: Question) -> Int? {
        questions.firstIndex(of: question)
    }
    
    var currentQuestionResolved: Question? {
        if let currentQuestion,
           questions.count > currentQuestion {
            return questions[currentQuestion]
        } else {
            return nil
        }
    }
    
    @Published var questionStage = 0 {
        didSet {
            if showMasterQuestion {
                questionStages["master"] = questionStage
            } else if let currentQuestionResolved {
                questionStages[currentQuestionResolved.id] = questionStage
            }
        }
    }
    
    @Published var questionStages = [String: Int]()
    
    @Published var questionsAnswered = [QuestionAnswer]()
    @Published var questionsExempt = [QuestionExemption]()
    
    @Published var isInStartStage = false
    
    @Published var baseScore = UInt(25)
    @Published var introTitle = "Konfifreizeit Quiz\n2023"
    
    @Published var pointsName = "Punkte"
    @Published var pointName = "Punkt"
    
    @Published var placeName = "Platz"
    @Published var answersName = "Antworten"
    
    @Published var questionName = "Frage"
    @Published var masterQuestionName = "Masterfrage"
    @Published var masterQuestionPrompt = "Setzt einen Teil eurer Punkte"
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
    
    @Published var allTeamsHaveBet = false
    
    func betUpdate() {
        allTeamsHaveBet = !getTeams().contains { team in
            team.betPts == nil
        }
    }
    
    func addTeam(name: String) throws {
        if teams.contains(where: {$0.name == name}) {
            throw QuizError.teamNameAlreadyExists
        }
        teams.append(Team(name: name))
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

enum QuizError: Error {
    case teamNameAlreadyExists
    case categoryNameAlreadyExists
    case questionWeightAlreadyExistsInCategory
}
