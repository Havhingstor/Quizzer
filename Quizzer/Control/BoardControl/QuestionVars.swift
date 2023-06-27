import Foundation
import Observation

@Observable
class QuestionVars {
    var questionObject = Question(question: "", answer: "", category: Category(name: ""), weight: 0)
    
    init(questionObject: Question) {
        self.questionObject = questionObject
    }
    
    var question: String {
        get {
            questionObject.question
        }
        set {
            questionObject.question = newValue
        }
    }
    
    var answer: String {
        get {
            questionObject.answer
        }
        set {
            questionObject.answer = newValue
        }
    }
    
    var category: UUID {
        get {
            questionObject.category
        }
        set {
            questionObject.category = newValue
        }
    }
    
    var weight: UInt {
        get {
            questionObject.weight
        }
        set {
            questionObject.weight = newValue
        }
    }
    
    var image: NamedData? {
        get {
            questionObject.image
        }
        set {
            questionObject.image = newValue
        }
    }
    
    var solutionImage: NamedData? {
        get {
            questionObject.solutionImage
        }
        set {
            questionObject.solutionImage = newValue
        }
    }
}
