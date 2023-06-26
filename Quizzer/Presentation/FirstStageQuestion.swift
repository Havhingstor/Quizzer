import SwiftUI

struct FirstStageQuestion: View {
    @Binding var question: Question
    
    @EnvironmentObject private var currentState: CurrentState
    
    var baseScore: UInt {
        currentState.baseScore
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 10)
                .fill(question.shouldOpen ? .red : .black
                )
                .frame(width: 225, height: 150)
            Text("\(question.categoryObject?.name ?? "N/A")\n\(question.weight * baseScore)")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
        }
        .opacity(question.shouldOpen ? 1.0 : 0.35)
    }
}
