import Foundation

struct MasterQuestion: QuestionViewProperties {
    let question: String
    let answerInternal: Int
    var answer: String {
        "\(answerInternal)"
    }
    let image: String?
    let solutionImage: String?
}
