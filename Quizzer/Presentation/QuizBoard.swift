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
            } else if let question = currentState.currentQuestion {
                QuestionView(question: question)
            } else {
                FirstStage()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
