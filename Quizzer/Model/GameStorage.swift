import Foundation
import SwiftUI
import UniformTypeIdentifiers
import ZIPFoundation
import OSLog

struct GameContainer: Codable, Equatable {
    static func == (lhs: GameContainer, rhs: GameContainer) -> Bool {
        let precondition = lhs.showMasterQuestion == rhs.showMasterQuestion &&
        lhs.showResults == rhs.showResults &&
        lhs.resultsStage == rhs.resultsStage &&
        lhs.currentQuestion == rhs.currentQuestion &&
        lhs.currentImage == rhs.currentImage &&
        lhs.questionStage == rhs.questionStage &&
        lhs.questionStages == rhs.questionStages &&
        lhs.questionsAnswered == rhs.questionsAnswered &&
        lhs.questionsExempt == rhs.questionsExempt &&
        lhs.isInStartStage == rhs.isInStartStage &&
        lhs.lastFileName == rhs.lastFileName &&
        lhs.teams.count == rhs.teams.count
        
        if precondition {
            for i in 0..<lhs.teams.count {
                let lhsTeam = lhs.teams[i]
                let rhsTeam = rhs.teams[i]
                
                if lhsTeam.id != rhsTeam.id || lhsTeam.name != rhsTeam.name {
                    return false
                }
            }
        }
        
        return precondition
    }
    
    var currentState: CurrentState {
        CurrentState.shared
    }
    
    var showMasterQuestion = false {
        didSet {
            if showMasterQuestion,
               let masterQuestion = currentState.masterQuestion {
                questionStages[masterQuestion.id] = questionStage
            } else if let resolved = currentState.currentQuestionResolved {
                questionStages[resolved.id] = questionStage
            }
        }
    }
    var showResults = false {
        didSet {
            resultsStage = 0
        }
    }
    var resultsStage = 0
    var currentQuestion: Int? = nil {
        didSet {
            guard let currentQuestion else { return }
            if let question = getCurrentQuestion(index: currentQuestion) {
                if let stage = questionStages[question.id] {
                    questionStage = stage
                } else {
                    questionStage = 0
                }
            }
            currentImage = nil
        }
    }
    
    private func getCurrentQuestion(index: Int) -> Question? {
        let list = currentState.questions
        
        guard index < list.count else {return nil}
        return currentState.questions[index]
    }
    
    var currentImage: NamedData? = nil
    var questionStage = 0 {
        didSet {
            let questions = currentState.questions
            if let currentQuestion,
               currentQuestion < questions.count {
                let question = currentState.questions[currentQuestion]
                questionStages[question.id] = questionStage
            }
        }
    }
    var questionStages = [UUID: Int]()
    var questionsAnswered = [QuestionAnswer]()
    var questionsExempt = [QuestionExemption]()
    var isInStartStage = true
    var teams = [Team]() {
        didSet {
            currentState.fixNextTeam()
        }
    }
    var lastFileName = nil as String?
}

struct GameStorage {
    static var readableContentTypes = [UTType.gameDocument]
    
    var container: GameContainer
    var quiz: StorageContainer
    
    init(data: Data) throws {
        guard let archive = Archive(data: data, accessMode: .read),
              let mainEntry = archive["game.json"],
              let quizEntry = archive["quiz.quiz"] else { throw StorageError.CouldNotReadArchive }
        
        var mainData = Data()
        _ = try archive.extract(mainEntry, skipCRC32: true) { data in
            mainData.append(data)
        }
        
        var quizData = Data()
        _ = try archive.extract(quizEntry, skipCRC32: true) { data in
            quizData.append(data)
        }
        
        container = try JSONDecoder().decode(GameContainer.self, from: mainData)
        quiz = try StorageContainer(data: quizData)
    }
    
    func encode() throws -> Data {
        guard let archive = Archive(accessMode: .create) else {throw StorageError.CouldNotCreateArchive}
        
        let mainData = try JSONEncoder().encode(container)
        
        try archive.addEntry(with: "game.json", type: .file, uncompressedSize: Int64(mainData.count), compressionMethod: .deflate) { position, size in
            let startPos = Int(position)
            let endPos = startPos + size
            
            return mainData.subdata(in: startPos..<endPos)
        }
        
        let quizData = CurrentState.shared.storageContainerData
        
        try archive.addEntry(with: "quiz.quiz", type: .file, uncompressedSize: Int64(quizData.count), compressionMethod: .deflate) { position, size in
            let startPos = Int(position)
            let endPos = startPos + size
            
            return quizData.subdata(in: startPos..<endPos)
        }
        
        guard let data = archive.data else {throw StorageError.CouldNotCreateArchive}
        
        return data
    }
    
    init() {
        container = CurrentState.shared.gameContainer
        quiz = CurrentState.shared.storageContainer
    }
}

extension UTType {
    static let gameDocument = UTType(exportedAs: "de.paulschuetz.gameDocument")
}
