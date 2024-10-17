import Foundation

struct MasterQuestion: Codable, Identifiable {
    let question: String
    let answerInternal: Int
    var answer: String {
        if options.count > answerInternal {
            options[answerInternal]
        } else {
            "N/A"
        }
    }
    let optionsInternal: [String]
    var options: [String] {
        optionsInternal.enumerated().map { index, option in
            "\(MasterQuestion.getAlphabeticalNr(for: UInt(index))): \(option)"
        }
    }
    private(set) var id = UUID()
    
    static func getAlphabeticalNr(for num: UInt) -> String {
        let higherOrderNumber = num / 26
        let higherOrderStr = higherOrderNumber > 0 ? getAlphabeticalNr(for: higherOrderNumber - 1) : ""
        
        let lowerOrderNumber = num % 26
        let aIndex = Unicode.Scalar("A").value
        let newIndex = aIndex + UInt32(lowerOrderNumber)
        return "\(higherOrderStr)\(Unicode.Scalar(newIndex)?.description ?? "")"
    }
    
    let image: NamedData?
    let solutionImage: NamedData?
}
