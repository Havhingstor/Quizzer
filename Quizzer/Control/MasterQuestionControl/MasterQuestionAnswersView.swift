import SwiftUI

struct MasterQuestionAnswersView: View {
    @EnvironmentObject private var currentState: CurrentState
    
    var body: some View {
        VStack {
            Text("Answers:")
                .font(.title2)
            ScrollView {
                ForEach(currentState.getTeams()) { team in
                    HStack {
                        Spacer()
                        AnswerTextView(team: team)
                        Spacer()
                    }
                }
            }
            .hide(if: currentState.questionStage < 2)
        }
        .padding(.top)
    }
}

struct AnswerTextView: View {
    @EnvironmentObject private var currentState: CurrentState
    
    @ObservedObject var team: Team
    
    var selectedAnswerStr: String {
        if let question = currentState.masterQuestion,
           question.options.count > team.masterQstAnswer {
            return question.options[team.masterQstAnswer]
        } else {
            return "N/A"
        }
    }
    
    var body: some View {
        VStack {
            Text(team.name)
                .font(.title3)
            Picker("Answer", selection: $team.masterQstAnswer) {
                if let question = currentState.masterQuestion {
                    let options = question.options.enumerated().map({($0.offset, $0.element)})
                    ForEach(options, id: \.0) { (index, opt) in
                        Text("\(opt)").tag(index)
                    }
                }
            }
            .labelsHidden()
        }
        .padding(5)
        
    }
}
