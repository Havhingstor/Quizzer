import SwiftUI

struct MasterQuestionAndAnswer: View {
    @EnvironmentObject private var currentState: CurrentState
    
    @Binding var question: MasterQuestion?
    
    func getHeight(text: String) -> Double {
        let noOfLines = text.split(separator: "\n").count
        return Double(noOfLines) * 20
    }
    
    var body: some View {
        if let question {
            GroupBox {
                VStack {
                    Text("Question")
                    Text(question.question)
                        .font(.headline)
                        .italic()
                        .frame(minHeight: getHeight(text: question.question))
                }
                .padding([.bottom, .leading, .trailing])
                
                let optionsList = Array(question.options.enumerated())
                
                VStack {
                    Text("Answer")
                    ForEach(optionsList, id: \.offset) { offset, element in
                        Text("\(element)")
                            .frame(minHeight: getHeight(text: element))
                            .padding(3)
                            .padding(.horizontal)
                            .background {
                                if offset == question.answerInternal {
                                    Color.accentColor
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                }
                            }
                            .foregroundStyle(currentState.questionStage == offset + 2 ? .red : .primary)
                    }
                }
            } label: {
                Text("Question &\nTrue Answer")
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .fixedSize()
            }
            .padding()
        }
    }
}
