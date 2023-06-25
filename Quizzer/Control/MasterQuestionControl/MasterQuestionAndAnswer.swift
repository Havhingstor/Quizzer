import SwiftUI

struct MasterQuestionAndAnswer: View {
    @EnvironmentObject private var currentState: CurrentState
    
    @Binding var question: MasterQuestion?
    
    var body: some View {
        if let question {
            GroupBox {
                VStack {
                    Text("Question")
                    Text(question.question)
                        .font(.headline)
                        .italic()
                }
                .padding([.bottom, .leading, .trailing])
                
                let optionsList = Array(question.options.enumerated())
                
                VStack {
                    Text("Answer")
                    ForEach(optionsList, id: \.offset) { offset, element in
                        Text("\(element)")
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
