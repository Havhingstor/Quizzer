import SwiftUI

struct MasterQuestionView: View {
    @EnvironmentObject var currentState: CurrentState
    
    @Binding var question: MasterQuestion
    
    var body: some View {
        VStack {
            Text(currentState.masterQuestionName)
                .font(.custom("SF Pro", size: 60.0))
                .padding()
                .background(.gray.opacity(0.75))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
            
            Spacer()
            
            if currentState.questionStage < 2 {
                Text(currentState.masterQuestionPrompt)
                    .font(.custom("SF Pro", size: 35))
                    .padding()
                    .background(.gray.opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
                
                VStack {
                    ForEach(currentState.getTeams()) { team in
                        let pointStr = abs(team.overallPoints) != 1 ? currentState.pointsName : currentState.pointName
                        Text("\(team.name):\t\(team.overallPoints) \(pointStr)")
                            .padding()
                    }
                }
                .font(.custom("SF Pro", size: 44))
                .padding()
                .background(.gray.opacity(0.75))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                .hide(if: currentState.questionStage < 1)
                
            } else {
                HStack {
                    VStack {
                        Text("\(currentState.questionName):")
                            .padding()
                        Text("\(question.question)")
                            .padding()
                    }
                    .font(.custom("SF Pro", size: 44.0))
                    .background(.gray.opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding([.top, .trailing, .bottom])
                    .padding(.leading, 60)
                    Spacer()
                    
                    if let imageName = question.image,
                       let cgImage = currentState.images[imageName] {
                        Image(cgImage, scale: 1.0, label: Text("Question Image"))
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .padding(.trailing)
                    }
                }
                Spacer()
                HStack {
                    VStack {
                        Text("\(currentState.answerName):")
                            .padding()
                        Text("\(question.answer)")
                            .padding()
                    }
                    .font(.custom("SF Pro", size: 44.0))
                    .background(.gray.opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding([.top, .trailing, .bottom])
                    .padding(.leading, 60)
                    .padding([.top, .trailing], 20)
                    Spacer()
                }
                .hide(if: currentState.questionStage < 3)
            }
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
