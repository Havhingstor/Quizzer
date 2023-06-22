import SwiftUI

struct MasterQuestionControl: View {
    @EnvironmentObject var currentState: CurrentState
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
                
                Button("Show End Points") {
                    for team in currentState.getTeams() {
                        print("\(team.name): \(team.endPoints)")
                    }
                }
                
                //            PresentationControls(holder: holder, question: $question)
                //
                //            Group {
                //                AnswerControl(holder: holder, question: $question, answer: $answer, team: team, goToControl: goToControl, registerAnswer: registerAnswer)
                //
                //                PreviousAnswer(holder: holder, question: $question, answer: $answer, teamInternal: $teamInternal, goToControl: goToControl)
                //            }
                //            .hide(if: question.exempt)
                //
                //            ExemptView(holder: holder, question: $question)
            }
            .padding()
            .frame(minWidth: 350, minHeight: 550)
            .fixedSize(horizontal: true, vertical: false)
            .onAppear {
                for team in currentState.getTeams() {
                    team.betPts = nil
                    team.masterQstAnswer = 0
                }
            }
        }
    }
}

struct MasterQuestionAndAnswer: View {
    @Binding var question: MasterQuestion?
    
    var body: some View {
        if let question {
            GroupBox {
                VStack {
                    Text("Question")
                    Text(question.question)
                        .font(.headline)
                        .italic()
                }
                .padding([.bottom, .leading, .trailing])
                
                let optionsList = Array(question.options.enumerated())
                
                VStack {
                    Text("Answer")
                    ForEach(optionsList, id: \.offset) { offset, element in
                        Text("\(element)")
                            .padding(3)
                            .padding(.horizontal)
                            .background {
                                if offset == question.answerInternal {
                                    Color.accentColor
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                }
                            }
                    }
                }
            } label: {
                Text("Question &\nTrue Answer")
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .fixedSize()
            }
            .padding()
        }
    }
}

struct MasterQuestionPresentationControls: View {
    @EnvironmentObject var currentState: CurrentState
    
    @Binding var question: MasterQuestion?
    
    var backButtonText: String {
        let stage = currentState.questionStage
        switch stage {
            case 1:
                return "Hide Point List"
            case 2:
                return "Go to Prompt Page"
            case 3...:
                return "Hide Option \(MasterQuestion.getAlphabeticalNr(for: UInt(stage - 3)))"
            default:
                return "Previous"
        }
    }
    
    var nextButtonText: String {
        let stage = currentState.questionStage
        switch stage {
            case 0:
                return "Show Points"
            case 1:
                return "Go to Question Page"
            case 2..<((question?.options.count ?? 0) + 2):
                return "Show Option \(MasterQuestion.getAlphabeticalNr(for: UInt(stage - 2)))"
            default:
                return "Next"
        }
    }
    
    var didBet: Bool {
        currentState.getTeams().filter { team in
            team.betPts == nil
        }.count == 0
    }
    
    var body: some View {
        HStack {
            Button(backButtonText) {
                withAnimation {
                    currentState.questionStage -= 1
                }
            }
            .disabled(currentState.questionStage < 1)
            Button(nextButtonText) {
                withAnimation {
                    currentState.questionStage += 1
                }
            }
            .disabled(currentState.questionStage > (1 + (question?.options.count ?? 0)) || (currentState.questionStage == 1 && !didBet))
        }
        .animation(.none, value: currentState.questionStage)
    }
}

struct MasterQuestionBettingView: View {
    @EnvironmentObject var currentState: CurrentState
    
    var body: some View {
        VStack {
            Text("Bets")
                .font(.title2)
            ScrollView {
                ForEach(currentState.getTeams()) { team in
                    HStack {
                        Spacer()
                        BetTextView(team: team)
                        Spacer()
                    }
                }
            }
            .hide(if: currentState.questionStage < 1)
        }
        .padding(.top)
    }
}

struct BetTextView: View {
    @ObservedObject var team: Team
    
    var body: some View {
        VStack {
            Text(team.name)
                .font(.title3)
            Text("Available: \(team.overallPoints)")
            TextField("Bet", value: $team.betPts, format: .number)
                .frame(width: 100)
                .multilineTextAlignment(.center)
        }
        .padding(5)
        
    }
}

struct MasterQuestionAnswersView: View {
    @EnvironmentObject var currentState: CurrentState
    
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
