import SwiftUI

struct QuestionView: View {
    @EnvironmentObject private var currentState: CurrentState

    @Binding var question: Question

    var titleText: String {
        return "\(question.categoryObject?.name ?? "N/A") - \(pointsText)"
    }

    var pointsText: String {
        let number = question.weight * currentState.baseScore
        
        let suffix: String
        if number == 1 {
            suffix = currentState.pointName
        } else {
            suffix = currentState.pointsName
        }
        
        return "\(number) \(suffix)"
    }

    var body: some View {
        VStack {
            Text(titleText)
                .font(.custom("SF Pro", size: 60.0))
                .padding()
                .background(.gray.opacity(0.75))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()

            Spacer()

            if question.question.lowercased() != "joker" {
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
                    
                    if let imageData = question.image?.data,
                       let image = NSImage(data: imageData) {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .padding(.trailing)
                    }
                }
                .hide(if: currentState.questionStage < 1)
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
                    .overlay(alignment: .topTrailing) {
                        Group {
                            if currentState.questionStage == 3 {
                                Image(systemName: "checkmark.seal.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 75)
                                    .foregroundColor(.green)
                            } else if currentState.questionStage > 3 {
                                Image(systemName: "xmark.seal.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 75)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    Spacer()
                }
                .hide(if: currentState.questionStage < 2)
                Spacer()
                Spacer()
            } else {
                Group {
                    Text("Joker")
                        .font(.custom("SF Pro", size: 90.0))
                        .foregroundStyle(.linearGradient(colors: [.blue, .green, .red], startPoint: .leading, endPoint: .trailing)).font(.custom("SF Pro", size: 60.0))
                        .padding()
                        .background(.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding()
                    Spacer()
                    Image("Joker")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 700)
                    Spacer()
                }
                .hide(if: currentState.questionStage < 1)
                .transition(.asymmetric(insertion: .scale.animation(.spring(response: 0.65, dampingFraction: 0.45)), removal: .identity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
