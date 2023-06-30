import Foundation
import Observation

struct StoredNamedData {
    let name: String
    let data: Data
    
    func toNamedData() -> NamedData {
        NamedData(name: name, data: data)
    }
    
    init?(_ namedData: NamedData?) {
        if let namedData {
            name = namedData.name
            data = namedData.data
        } else {
            return nil
        }
    }
    
    init(name: String, data: Data) {
        self.name = name
        self.data = data
    }
}

@Observable
class QuestionVars {
    
    init(questionObject: Question) {
        question = questionObject.question
        answer = questionObject.question
        category = questionObject.category
        weight = questionObject.weight
        image = StoredNamedData(questionObject.image)
        solutionImage = StoredNamedData(questionObject.solutionImage)
    }
    
    static func initFromMasterQuestion() -> QuestionVars {
        let result = QuestionVars()
        
        if let masterQuestion = CurrentState.shared.masterQuestion {
            result.question = masterQuestion.question
            result.image = StoredNamedData(masterQuestion.image)
            result.solutionImage = StoredNamedData(masterQuestion.solutionImage)
            result.options = masterQuestion.optionsInternal
            result.answerIndex = masterQuestion.answerInternal
            result.id = masterQuestion.id
        }
        
        return result
    }
    
    private init() {}
    
    var id = UUID()
    var question = ""
    var answer = ""
    var options = [String]()
    var answerIndex = 0
    var category = UUID()
    var weight = 0 as UInt
    
    var image = nil as StoredNamedData?
    var solutionImage = nil as StoredNamedData?
    
    func toQuestion() -> Question {
        let currentState = CurrentState.shared
        let categoryObj = currentState.categories.first(where: {$0.id == category}) ?? Category(name: "")
        return Question(question: question, answer: answer, category: categoryObj, weight: weight, image: image?.toNamedData(), solutionImage: solutionImage?.toNamedData())
    }
    
    func saveToMasterQuestion() {
        let currentState = CurrentState.shared
        currentState.masterQuestion = MasterQuestion(question: question, answerInternal: answerIndex, optionsInternal: options, id: id, image: image?.toNamedData(), solutionImage: solutionImage?.toNamedData())
    }
}
