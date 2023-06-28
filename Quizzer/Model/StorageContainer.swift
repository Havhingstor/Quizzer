import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct StorageContainer: Codable, FileDocument {
    static var readableContentTypes = [UTType.quizDocument]
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        try self.init(data: data)
    }
    
    init(data: Data) throws {
        self = try JSONDecoder().decode(StorageContainer.self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(self)
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        
        return fileWrapper
    }
    
    var questions = [Question]()
    var categories = [Category]()
    var masterQuestion = nil as MasterQuestion?
    
    init() {}
}

extension UTType {
    static let quizDocument = UTType(exportedAs: "de.paulschuetz.quizDocument")
}
