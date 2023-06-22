import SwiftUI

struct MasterQuestionView: View {
    @EnvironmentObject var currentState: CurrentState
    
    @Binding var question: MasterQuestion
    
    var optionsPaddingSize: CGFloat {
        if question.options.count > 0 {
            return CGFloat(48 / question.options.count)
        } else {
            return 0
        }
    }
    
    var optionsTextSize: CGFloat {
        if question.options.count > 0 {
            return CGFloat(140 / question.options.count)
        } else {
            return 0
        }
    }
    
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
                        TeamPointView(team: team)
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
                        VStack {
                            Text("\(currentState.questionName):")
                                .padding()
                            Text("\(question.question)")
                                .padding()
                        }
                        .font(.custom("SF Pro", size: 44.0))
                        .background(.gray.opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding()
                        
                        
                        VStack {
                            Text("\(currentState.answersName):")
                                .padding()
                                .font(.custom("SF Pro", size: 44.0))
                                .background(.gray.opacity(0.75))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding()
                            
                            
                            ForEach(Array(question.options.enumerated()), id: \.offset) { offset, element in
                                Text("\(element)")
                                    .padding(optionsPaddingSize)
                                    .background(.gray.opacity(0.75))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding(optionsPaddingSize)
                                    .hide(if: currentState.questionStage - 3 < offset)
                            }
                            .font(.custom("SF Pro", size: optionsTextSize))
                        }
                    }
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
            }
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TeamPointView: View {
    @EnvironmentObject var currentState: CurrentState
    
    @ObservedObject var team: Team
    
    var pointStr: String {
        if team.overallPoints != 1 {
            return currentState.pointsName
        } else {
            return currentState.pointName
        }
    }
    
    var body: some View {
        Text("\(team.name):\t\(team.overallPoints) \(pointStr)")
            .padding()
    }
}
