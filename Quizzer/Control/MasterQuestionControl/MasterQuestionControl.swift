import SwiftUI

struct MasterQuestionControl: View {
    @EnvironmentObject private var currentState: CurrentState
    @Environment(\.dismiss) var dismiss
    
    @Binding var question: MasterQuestion?
    
    var body: some View {
        if question != nil {
            VStack(alignment: .center) {
                Text("Master Question")
                    .font(.largeTitle)
                    .padding()
                
                MasterQuestionAndAnswer(question: $question)
                
                MasterQuestionPresentationControls(question: $question)
                
                HStack {
                    MasterQuestionBettingView()
                    MasterQuestionAnswersView()
                }
            }
            .padding()
            .frame(minWidth: 350, minHeight: 700)
            .fixedSize(horizontal: true, vertical: false)
        }
    }
}

