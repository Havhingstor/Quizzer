import Foundation
import SwiftUI
import OSLog

class CurrentState: ObservableObject {
    static var examples: CurrentState {
        shared.pauseReloading = true
        let hrrURL = Bundle.main.url(forResource: "HRR", withExtension: "jpg")!
        let kaiserURL = Bundle.main.url(forResource: "Kaiser", withExtension: "jpg")!
        
        let hrrData, kaiserData: Data
        
        if let data = try? Data(contentsOf: hrrURL) {
            hrrData = data
        } else {
            hrrData = Data()
        }
        
        if let data = try? Data(contentsOf: kaiserURL) {
            kaiserData = data
        } else {
            kaiserData = Data()
        }
        
        shared.categories = [
            Category(name: "Allgemeinwissen"),
            Category(name: "Religionen"),
            Category(name: "Christentum"),
            Category(name: "Geographie"),
            Category(name: "Politik")
        ]
        
        
        shared.questions = [
            Question(question: "Q1", answer: "A1", category: shared.categories[0], weight: 1, image: NamedData(name: "HRR", data: hrrData), solutionImage: NamedData(name: "Kaiser", data: kaiserData)),
            Question(question: "Q2", answer: "A2", category: shared.categories[0], weight: 2),
            Question(question: "Q3", answer: "A3", category: shared.categories[0], weight: 3),
            Question(question: "Q4", answer: "A4", category: shared.categories[0], weight: 4),
            Question(question: "Q5", answer: "A5", category: shared.categories[1], weight: 1),
            Question(question: "Q6", answer: "A6", category: shared.categories[1], weight: 2),
            Question(question: "Q7", answer: "A7", category: shared.categories[1], weight: 3),
            Question(question: "Q8", answer: "A8", category: shared.categories[1], weight: 4),
            Question(question: "Q9", answer: "A9", category: shared.categories[2], weight: 1),
            Question(question: "Q10", answer: "A10", category: shared.categories[2], weight: 2),
            Question(question: "Q11", answer: "A11", category: shared.categories[2], weight: 3),
            Question(question: "Joker", answer: "A12", category: shared.categories[2], weight: 4),
            Question(question: "Q13", answer: "A13", category: shared.categories[3], weight: 1),
            Question(question: "Q14", answer: "A14", category: shared.categories[3], weight: 2),
            Question(question: "Q15", answer: "A15", category: shared.categories[3], weight: 3),
            Question(question: "Q16", answer: "A16", category: shared.categories[3], weight: 4),
            Question(question: "Q17", answer: "A17", category: shared.categories[4], weight: 1),
            Question(question: "Q18", answer: "A18", category: shared.categories[4], weight: 2),
            Question(question: "Q19", answer: "A19", category: shared.categories[4], weight: 3),
            Question(question: "Q17", answer: "A20", category: shared.categories[4], weight: 4),
        ]
        shared.masterQuestion = MasterQuestion(question: "Welche?", answerInternal: 2, optionsInternal: ["1","2","3","4"], image: NamedData(name: "Kaiser", data: kaiserData), solutionImage: NamedData(name: "HRR", data: hrrData))
        
        shared.pauseReloading = false
        
        shared.teams = [
            Team(name: "Team A"),
            Team(name: "Team B"),
            Team(name: "Team C"),
            Team(name: "Team D")
        ]
        
        for (index, team) in shared.teams.enumerated() {
            team.addedPoints = index
        }
        
        return shared
    }
    
    private init() {}
    
    static let defaultTeam = Team(name: "Default Team")
    
    static let shared = CurrentState()
    
    var lastFileName: String? {
        get {
            gameContainer.lastFileName
        }
        set {
            gameContainer.lastFileName = newValue
        }
    }
    
    @Published var storageContainer = StorageContainer() {
        didSet {
            isInStartStage = categories.filter { $0.isShown }.count == 0
            questionsAnswered = questionsAnswered.filter { answer in
                questions.contains { question in
                    question.id == answer._question
                }
            }
            
            questionsExempt = questionsExempt.filter { exemption in
                questions.contains { question in
                    question.id == exemption._question
                }
            }
            
            reloadStorageContainerData()
        }
    }
    
    private func reloadStorageContainerData() {
        if !pauseReloading {
            guard let data = getStorageContainerData() else { return }
            storageContainerDataInternal = data
        }
    }
    
    private func getStorageContainerData() -> Data? {
        do {
            return try storageContainer.encode()
        } catch {
            let logger = Logger(subsystem: "de.paulschuetz.Quizzer", category: "FileIO")
            logger.warning("Couldn't create data from storage container: \(error, privacy: .public)")
        }
        
        return nil
    }
    
    private var pauseReloading = false {
        didSet {
            reloadStorageContainerData()
        }
    }
    
    @Published private var storageContainerDataInternal = (try? StorageContainer().encode()) ?? Data()
    
    var storageContainerData: Data {
        if pauseReloading,
           let data = getStorageContainerData() {
            return data
        } else {
            return storageContainerDataInternal
        }
    }
    
    @Published var gameContainer = GameContainer() {
        didSet {
            if !getTeams().contains(nextTeam) {
                nextTeam = getTeams().first!
            }
        }
    }
    
    func resetQuiz() {
        storageContainer = StorageContainer()
    }
    
    func resetGame() {
        let lastFileName = gameContainer.lastFileName
        gameContainer = GameContainer()
        gameContainer.lastFileName = lastFileName
    }
    
    var categories: [Category] {
        get {
            storageContainer.categories
        }
        set {
            storageContainer.categories = newValue
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
    
    func editCategory(_ category: Category, newName: String) {
        for i in 0..<categories.count {
            if categories[i].id == category.id {
                categories[i].name = newName
            }
        }
    }
    
    func deleteCategory(_ category: Category) {
        questions.filter { question in
            question.category == category.id
        }.forEach { question in
            deleteQuestion(question)
        }
        
        categories.removeAll { item in
            item.id == category.id
        }
    }
    
    var questions: [Question] {
        get {
            storageContainer.questions
        }
        set {
            storageContainer.questions = newValue
        }
    }
    
    var masterQuestion: MasterQuestion? {
        get {
            storageContainer.masterQuestion
        }
        set {
            storageContainer.masterQuestion = newValue
        }
    }
    
    func testExistenceOfQuestionParams(weight: UInt, category: Category.ID) -> Bool {
        for questionItem in questions {
            if questionItem.category == category,
               questionItem.weight == weight {
                return true
            }
        }
        
        return false
    }
    
    public func addQuestion(question: Question) throws {
        if testExistenceOfQuestionParams(weight: question.weight, category: question.category) {
            throw QuizError.questionWeightAlreadyExistsInCategory
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
    
    var showMasterQuestion: Bool {
        get {
            gameContainer.showMasterQuestion
        }
        set {
            gameContainer.showMasterQuestion = newValue
        }
    }
    
    var showResults: Bool {
        get {
            gameContainer.showResults
        }
        set {
            gameContainer.showResults = newValue
        }
    }
    
    var resultsStage: Int {
        get {
            gameContainer.resultsStage
        }
        set {
            gameContainer.resultsStage = newValue
        }
    }
    
    var currentQuestion: Int? {
        get {
            gameContainer.currentQuestion
        }
        set {
            gameContainer.currentQuestion = newValue
        }
    }
    
    var currentImage: NamedData? {
        get {
            gameContainer.currentImage
        }
        set {
            gameContainer.currentImage = newValue
        }
    }
    
    var questionStage: Int {
        get {
            gameContainer.questionStage
        }
        set {
            gameContainer.questionStage = newValue
        }
    }
    
    var questionStages: [UUID: Int] {
        get {
            gameContainer.questionStages
        }
        set {
            gameContainer.questionStages = newValue
        }
    }
    
    var questionsAnswered: [QuestionAnswer] {
        get {
            gameContainer.questionsAnswered
        }
        set {
            gameContainer.questionsAnswered = newValue
        }
    }
    
    var questionsExempt: [QuestionExemption] {
        get {
            gameContainer.questionsExempt
        }
        set {
            gameContainer.questionsExempt = newValue
        }
    }
    
    var isInStartStage: Bool {
        get {
            gameContainer.isInStartStage
        }
        set {
            gameContainer.isInStartStage = newValue
        }
    }
    
    private var teams: [Team] {
        get {
            gameContainer.teams
        }
        set {
            gameContainer.teams = newValue
        }
    }
    
    @Published var introTitle = "Konfifreizeit Quiz\n2023"
    
    @Published var pointsName = "Punkte"
    @Published var pointName = "Punkt"
    
    @Published var placeName = "Platz"
    @Published var answersName = "Antworten"
    
    @Published var questionName = "Frage"
    @Published var masterQuestionName = "Masterfrage"
    @Published var masterQuestionPrompt = "Setzt einen Teil eurer Punkte"
    @Published var answerName = "Antwort"
    
    
    
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
            return [Self.defaultTeam]
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
    
    func fixNextTeam() {
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
    case optionAlreadyExists
    case appDirectoryDoesntExist
}
