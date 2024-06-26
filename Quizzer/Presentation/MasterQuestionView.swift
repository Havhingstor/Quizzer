import SwiftUI

struct MasterQuestionView: View {
    @EnvironmentObject private var currentState: CurrentState
    
    @Binding var question: MasterQuestion
    
    var optionsPaddingSize: CGFloat {
        if question.options.count > 0 {
            return CGFloat(48 / optionsLineNr)
        } else {
            return 0
        }
    }
    
    var optionsLineNr: Double {
        var count = 0.0
        for option in question.options {
            count += 1
            count += (Double(option.components(separatedBy: "\n").count) - 1)// * 1.5
        }
        
        return count
    }
    
    var optionsTextSize: CGFloat {
        if question.options.count > 0 {
            return min(CGFloat(210 / optionsLineNr), 44)
        } else {
            return 0
        }
    }
    
    func shouldShowAsCorrectAnswer(index: Int) -> Bool {
        question.answerInternal == index && currentState.questionStage > question.options.count + 2
    }
    
    var body: some View {
        VStack {
            Text(currentState.masterQuestionName)
                .font(.custom("SF Pro", size: 60.0))
                .padding()
                .opaqueBackground()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
            
            Spacer()
            
            if currentState.questionStage < 2 {
                Text(currentState.masterQuestionPrompt)
                    .font(.custom("SF Pro", size: 35))
                    .padding()
                    .opaqueBackground()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
                
                VStack {
                    ForEach(currentState.getTeams()) { team in
                        TeamPointView(team: team)
                    }
                }
                .font(.custom("SF Pro", size: 44))
                .padding()
                .opaqueBackground()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                .hide(if: currentState.questionStage < 1)
                
            } else {
                HStack {
                    VStack (alignment: .leading) {
                        VStack {
                            Text("\(currentState.questionName):")
                                .padding()
                            Text("\(question.question)")
                                .padding()
                        }
                        .font(.custom("SF Pro", size: 44.0))
                        .opaqueBackground()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding()
                        
                        
                        VStack (alignment: .leading) {
                            Text("\(currentState.answersName):")
                                .padding()
                                .font(.custom("SF Pro", size: 44.0))
                                .opaqueBackground()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding()
                            
                            
                            ForEach(Array(question.options.enumerated()), id: \.offset) { offset, element in
                                let correct = shouldShowAsCorrectAnswer(index: offset)
                                Text("\(element)")
                                    .padding(optionsPaddingSize)
                                    .padding(.trailing, correct ? optionsTextSize * 2 : 0)
                                    .overlay(alignment: .trailing) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: optionsTextSize * 1.5)
                                            .foregroundColor(.green)
                                            .hide(if: !correct)
                                    }
                                    .conditionalModifier { view in
                                        if correct {
                                            return view.background {Color.accentColor}
                                        } else {
                                            return view.opaqueBackground()
                                        }
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding(.bottom, optionsPaddingSize)
                                    .hide(if: currentState.questionStage - 3 < offset)
                            }
                            .font(.custom("SF Pro", size: optionsTextSize))
                            .padding(.leading)
                        }
                    }
                    .padding([.top, .trailing, .bottom])
                    .padding(.leading, 60)
                    Spacer()
                    
                    if let imageData = question.image?.data,
                       let image = NSImage(data: imageData) {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .padding(.trailing)
                            .animation(.none, value: currentState.questionStage)
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
    @EnvironmentObject private var currentState: CurrentState
    
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
