import SwiftUI

struct QuizBoard: View {
    @EnvironmentObject var currentState: CurrentState
    
    var body: some View {
        ZStack {
            Image("Background")
                .resizable()
                .scaledToFit()
                .opacity(currentState.isInStartStage ? 1.0 : 0.5)
            
            if currentState.isInStartStage {
                Text(currentState.introTitle)
                    .font(.custom("SF Pro Rounded", size: 80.0))
                    .multilineTextAlignment(.center)
                    .padding()
                    .padding()
                    .background(.gray.opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else if let currentImageStr = currentState.currentImage,
                      let currentImage = currentState.images[currentImageStr] {
                Image(currentImage, scale: 1.0, label: Text("Solution Image"))
                    .resizable()
                    .scaledToFit()
                    .padding()
            } else if let question = currentState.masterQuestion,
                      currentState.showMasterQuestion {
                let questionBinding = Binding<QuestionViewProperties>(get: {
                    question
                }, set: { newValue in
                    if let newQuestion = newValue as? MasterQuestion {
                        currentState.masterQuestion = newQuestion
                    }
                })
                QuestionView(question: questionBinding)
            } else if let question = currentState.currentQuestionResolved {
                let questionBinding = Binding<QuestionViewProperties>(get: {
                    question
                }, set: { newValue in
                    if let newQuestion = newValue as? Question {
                        currentState.currentQuestion = currentState.getIndexOfQuestion(newQuestion)
                    }
                })
                QuestionView(question: questionBinding)
            } else {
                FirstStage()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
