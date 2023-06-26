import SwiftUI

struct QuizBoard: View {
    @EnvironmentObject private var currentState: CurrentState
    
    var body: some View {
        ZStack {
            Image("Background")
                .resizable()
                .scaledToFit()
                .opacity(currentState.isInStartStage ? 1.0 : 0.5)
            
            if let currentImageData = currentState.currentImage?.data,
               let currentImage = NSImage(data: currentImageData) {
                Image(nsImage: currentImage)
                    .resizable()
                    .scaledToFit()
                    .padding()
            } else if currentState.showResults {
                ResultsView()
            } else if let question = currentState.masterQuestion,
                      currentState.showMasterQuestion {
                let questionBinding = Binding<MasterQuestion>(get: {
                    question
                }, set: { newValue in
                    currentState.masterQuestion = newValue
                })
                MasterQuestionView(question: questionBinding)
            } else if currentState.isInStartStage {
                Text(currentState.introTitle)
                    .font(.custom("SF Pro Rounded", size: 80.0))
                    .multilineTextAlignment(.center)
                    .padding()
                    .padding()
                    .background(.gray.opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else if let question = currentState.currentQuestionResolved {
                let questionBinding = Binding<Question>(get: {
                    question
                }, set: { newValue in
                    currentState.currentQuestion = currentState.getIndexOfQuestion(newValue)
                })
                QuestionView(question: questionBinding)
            } else {
                FirstStage()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
