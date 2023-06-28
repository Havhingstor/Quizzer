import Foundation
import Observation

class QuestionVars: ObservableObject {
    
    init(questionObject: Question) {
        question = questionObject.question
        answer = questionObject.question
        category = questionObject.category
        weight = questionObject.weight
        image = questionObject.image
        solutionImage = questionObject.solutionImage
    }
    
    static func initFromMasterQuestion() -> QuestionVars {
        let result = QuestionVars()
        
        if let masterQuestion = CurrentState.shared.masterQuestion {
            result.question = masterQuestion.question
            result.image = masterQuestion.image
            result.solutionImage = masterQuestion.solutionImage
            result.options = masterQuestion.optionsInternal
            result.answerIndex = masterQuestion.answerInternal
            result.id = masterQuestion.id
        }
        
        return result
    }
    
    private init() {}
    
    @Published var question = ""
    @Published var answer = ""
    @Published var options = [String]()
    @Published var answerIndex = 0
    @Published var category = UUID()
    @Published var weight = 0 as UInt
    var image = nil as NamedData? 
    var solutionImage = nil as NamedData?
    @Published var id = UUID()
    
    func toQuestion() -> Question {
        let currentState = CurrentState.shared
        let categoryObj = currentState.categories.first(where: {$0.id == category}) ?? Category(name: "")
        return Question(question: question, answer: answer, category: categoryObj, weight: weight, image: image, solutionImage: solutionImage)
    }
    
    func saveToMasterQuestion() {
        let currentState = CurrentState.shared
        currentState.masterQuestion = MasterQuestion(question: question, answerInternal: answerIndex, optionsInternal: options, id: id, image: image, solutionImage: solutionImage)
    }
}
