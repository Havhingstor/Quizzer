import Foundation
import SwiftUI
import UniformTypeIdentifiers
import ZIPFoundation
import OSLog

fileprivate struct JSONEncoded: Codable {
    var questions: [Question]
    var categories: [Category]
    var masterQuestion: MasterQuestion?
    var checksums = [Int: CRC32]()
    var baseScore = UInt(25)
    
    init(container: StorageContainer) {
        self.questions = container.questions
        self.categories = container.categories
        self.masterQuestion = container.masterQuestion
        self.baseScore = container.baseScore
    }
}

struct StorageContainer: FileDocument {
    static var readableContentTypes = [UTType.quizDocument]
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        try self.init(data: data)
    }
    
    init(data: Data) throws {
        let logger = Logger(subsystem: "de.paulschuetz.Quizzer", category: "FileIO")
        guard let archive = Archive(data: data, accessMode: .read),
            let mainEntry = archive["main.json"] else { throw StorageError.CouldNotReadArchive }
        
        var jsonData = Data()
        _ = try archive.extract(mainEntry, skipCRC32: true) { data in
            jsonData.append(data)
        }
        let jsonEncoded = try JSONDecoder().decode(JSONEncoded.self, from: jsonData)
        
        questions = jsonEncoded.questions
        masterQuestion = jsonEncoded.masterQuestion
        categories = jsonEncoded.categories
        baseScore = jsonEncoded.baseScore
        
        for entry in archive {
            guard entry.path != "main.json" else {continue}
            guard let hash = Int(entry.path),
                  entry.checksum == jsonEncoded.checksums[hash] else {
                logger.warning("Couldn't decode \(entry.path, privacy: .public), checksum \(entry.checksum)")
                continue
            }
            
            var imageData = Data()
            
            _ = try? archive.extract(entry, skipCRC32: true, consumer: { data in
                imageData.append(data)
            })
            
            guard imageData.count > 0 else {
                logger.warning("Couldn't decode \(entry.path, privacy: .public), checksum \(entry.checksum)")
                continue
            }
            
            images[hash] = imageData
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        var jsonEncoded = JSONEncoded(container: self)
        
        guard let archive = Archive(accessMode: .create) else {throw StorageError.CouldNotCreateArchive}
        
        for (hash, image) in images {
            try archive.addEntry(with: "\(hash)", type: .file, uncompressedSize: Int64(image.count), compressionMethod: .deflate) { position, size in
                let startPos = Int(position)
                let endPos = startPos + size
                
                return image.subdata(in: startPos..<endPos)
            }
            
            guard let checksum = archive["\(hash)"]?.checksum else { continue }
            
            jsonEncoded.checksums[hash] = checksum
        }
        
        let jsonData = try JSONEncoder().encode(jsonEncoded)
        
        try archive.addEntry(with: "main.json", type: .file, uncompressedSize: Int64(jsonData.count), compressionMethod: .deflate) { position, size in
            let startPos = Int(position)
            let endPos = startPos + size
            
            return jsonData.subdata(in: startPos..<endPos)
        }
        
        guard let data = archive.data else {throw StorageError.CouldNotCreateArchive}
        
        return FileWrapper(regularFileWithContents: data)
    }
    
    var images = [Int: Data]()
    
    var questions = [Question]()
    var categories = [Category]()
    var masterQuestion = nil as MasterQuestion?
    var baseScore = UInt(25)
    
    init() {}
    
    mutating func cleanImages() {
        var hashes = Set(questions.map {$0.image?.data.hashValue}.filter({$0 != nil}).map({$0!}))
        
        hashes.formUnion(questions.map {$0.solutionImage?.data.hashValue}.filter({$0 != nil}).map({$0!}))
        
        if let masterQuestionImage = masterQuestion?.image {
            hashes.insert(masterQuestionImage.data.hashValue)
        }
        
        if let masterQuestionImage = masterQuestion?.solutionImage {
            hashes.insert(masterQuestionImage.data.hashValue)
        }
        
        let keys = images.keys
        
        for key in keys {
            guard !hashes.contains(key) else {continue}
            
            images.removeValue(forKey: key)
        }
    }
}

extension UTType {
    static let quizDocument = UTType(exportedAs: "de.paulschuetz.quizDocument")
}

enum StorageError: Error {
    case CouldNotReadArchive
    case CouldNotCreateArchive
}
