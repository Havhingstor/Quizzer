import SwiftUI

struct QuestionAndAnswer: View {
    @Binding var question: Question?
    
    var isJoker: Bool {
        question?.question.lowercased() == "joker"
    }
    
    var body: some View {
        if let question {
            if !isJoker {
                GroupBox {
                    VStack {
                        Text("Question")
                        Text(question.question)
                            .font(.headline)
                            .italic()
                    }
                    .padding([.bottom, .leading, .trailing])
                    
                    VStack {
                        Text("True Answer")
                        Text(question.answer)
                            .font(.headline)
                            .italic()
                    }
                } label: {
                    Text("Question &\nTrue Answer")
                        .multilineTextAlignment(.center)
                        .font(.title2)
                }
                .padding()
            } else {
                Text("Joker")
                    .font(.title)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
}
