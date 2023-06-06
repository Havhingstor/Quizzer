import Foundation

struct MasterQuestion: QuestionViewProperties {
    let question: String
    let answerInternal: Int
    var answer: String {
        "\(answerInternal)"
    }
}
