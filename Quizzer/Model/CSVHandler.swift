import Foundation
import CSV
import SwiftUI
import OSLog
import UniformTypeIdentifiers

func loadQuestionsAsCSV() -> Result<String, Error> {
    let currentState = CurrentState.shared
    
    let questionList = currentState.questions.sorted { lhs, rhs in
        lhs.weight < rhs.weight
    }
    
    let baseScore = currentState.storageContainer.baseScore
    
    return Result {
        let writer = try CSVWriter(stream: .toMemory())
        
        try writer.write(row: ["Category", "Score", "Question", "Answer"])
        
        for category in currentState.categories {
            let questionsOfCategory = questionList.filter { question in
                question.category == category.id
            }
            
            for question in questionsOfCategory {
                let score = question.weight * baseScore
                try writer.write(row: ["\(category.name)", "\(score)", "\(question.question)", "\(question.answer)"])
            }
        }
        
        writer.stream.close()
        
        let data = writer.stream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data
        
        guard let data,
              let string = String(data: data, encoding: .utf8) else {
            return "N/A"
        }
        
        return string
    }
}

struct CSVHandler: FileDocument {
    static var readableContentTypes = [UTType.commaSeparatedText]
    
    init(configuration: ReadConfiguration) throws {
        throw Errors.ReadingNotAllowedError
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = stringData.data(using: .utf8) else {throw Errors.WritingError}
        
        return FileWrapper(regularFileWithContents: data)
    }
    
    var stringData: String
    
    init() {
        let logger = Logger(subsystem: "de.paulschuetz.quizzer", category: "FileIO")
        
        switch loadQuestionsAsCSV() {
            case .success(let string):
                stringData = string
            case .failure(let error):
                logger.warning("Error when exporting: \(error)")
                stringData = ""
        }
    }
    
    enum Errors: Error {
        case ReadingNotAllowedError
        case WritingError
    }
}
