import SwiftUI
import AppKit

struct QuestionControl: View {
    @EnvironmentObject var currentState: CurrentState
    @Environment(\.dismiss) var dismiss
    
    @State var answer = ""
    @State var team: Team = Team(name: "No Team", currentState: CurrentState())
    @State var teamList: [Team] = [Team(name: "No Team", currentState: CurrentState())]

    var categoryAndPoints: String {
        let question = currentState.currentQuestion!
        return "\(question.wrappedValue.category) - \(Int(question.wrappedValue.weight) * currentState.baseScore)"
    }
    
    func isJoker(_ question: Binding<Question>) -> Bool {
        question.wrappedValue.question.lowercased() == "joker"
    }

    func registerAnswer(correct: Bool, for question: Binding<Question>) {
        withAnimation {
            question.wrappedValue.answered.toggle()
            currentState.currentQuestion = nil
        }
        dismiss()
    }
    
    var body: some View {
        if let question = currentState.currentQuestion {
            Form {
                Text(categoryAndPoints)
                    .font(.largeTitle)
                    .padding()

                
                Picker("Team", selection: $team) {
                    ForEach(teamList) { team in
                        Text("\(team.name)").tag(team)
                    }
                }
                .onAppear {
                    if currentState.teams.count > 0 {
                        teamList = currentState.teams
                        team = teamList.first!
                    }
                }
                
                if !isJoker(question) {
                    Section("Question & True Answer") {
                        LabeledContent {
                            Text(question.wrappedValue.question)
                                .italic()
                        } label: {
                            Text("Question")
                        }
                        LabeledContent {
                            Text(question.wrappedValue.answer)
                                .italic()
                        } label: {
                            Text("Answer")
                        }
                    }
                    .padding()
                } else {
                    Section {
                        Text("Joker")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                    .padding()
                }
                
                Section("Presentation") {
                    HStack {
                        Button("Previous") {
                            withAnimation {
                                currentState.questionStage -= 1
                                currentState.questionStage = max(currentState.questionStage, 0)
                            }
                        }
                        Button("Next") {
                            let max = isJoker(question) ? 1 : 2
                            withAnimation {
                                currentState.questionStage += 1
                                currentState.questionStage = min(currentState.questionStage, max)
                            }
                        }
                        
                        Text("Stage \(currentState.questionStage)")
                    }
                }
                
                if !isJoker(question) {
                    Section("Received Answer") {
                        TextField(text: $answer) {
                            Text("Answer")
                        }
                        Button("Register correct answer") {
                            registerAnswer(correct: true, for: question)
                        }
                        Button("Register wrong answer") {
                            registerAnswer(correct: true, for: question)
                        }
                    }
                } else {
                    Section {
                        Button("Claim") {
                            registerAnswer(correct: true, for: question)
                        }
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { output in
                let window = NSApplication.shared.windows.first(where: {$0.title == "Question"})
                if output.object as? NSWindow == window {
                    withAnimation {
                        currentState.currentQuestion = nil
                    }
                } else {
                    openingQL = false
                }
            }
            .padding()
            .fixedSize()
        } else {
            Text("No Question")
                .padding()
                .fixedSize()
                .onAppear {
                    dismiss()
                }
        }
    }
}

struct QuestionControl_Previews: PreviewProvider {
    static var previews: some View {
        QuestionControl()
    }
}
