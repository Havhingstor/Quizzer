import SwiftUI

struct MasterQuestionControl: View {
    @EnvironmentObject var currentState: CurrentState
    @Environment(\.dismiss) var dismiss
    
    @Binding var question: MasterQuestion?
    
    var body: some View {
        if let question {
            VStack(alignment: .center) {
                Text("Master Question")
                    .font(.largeTitle)
                    .padding()
                
                MasterQuestionAndAnswer(question: $question)
                
                MasterQuestionPresentationControls(question: $question)
                
//                MasterQuestionControl(question: $question)
                
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
            .frame(minWidth: 350)
            .fixedSize()
            .onAppear {
                currentState.showMasterQuestion = true
            }
            .onChange(of: currentState.showMasterQuestion) { _, newValue in
                if !newValue {
                    dismiss()
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
                
                VStack {
                    Text("True Answer")
                    Text("\(question.answer)")
                        .font(.headline)
                        .italic()
                }
            } label: {
                Text("Question &\nTrue Answer")
                    .multilineTextAlignment(.center)
                    .font(.title2)
            }
            .padding()
        }
    }
}

struct MasterQuestionPresentationControls: View {
    @EnvironmentObject var currentState: CurrentState
    
    @Binding var question: MasterQuestion?
    
    var backButtonText: String {
        switch currentState.questionStage {
            case 1:
                return "Hide Point List"
            case 2:
                return "Go to Prompt Page"
            case 3:
                return "Hide Answer"
            default:
                return "Previous"
        }
    }
    
    var nextButtonText: String {
        switch currentState.questionStage {
            case 0:
                return "Show Points"
            case 1:
                return "Go to Qustion Page"
            case 2:
                return "Show Answer"
            default:
                return "Next"
        }
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
            .disabled(currentState.questionStage > 2)
        }
        .animation(.none, value: currentState.questionStage)
    }
}

struct MasterQuestionBettingView: View {
    @EnvironmentObject var currentState: CurrentState
    
    var body: some View {
        Form {
            ForEach(currentState.getTeams()) { team in
                Section(team.name) {
                    Text("Available: \(team.overallPoints)")
                    BetTextView(team: team)
                }
            }
        }
    }
}

struct BetTextView: View {
    @ObservedObject var team: Team
    
    var body: some View {
        TextField("Bet", value: $team.betPts, format: .number)
    }
}
