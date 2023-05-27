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
                
                Section("Presentation") {
                    HStack {
                        Button("Next") {
                            withAnimation {
                                currentState.questionStage += 1
                                currentState.questionStage = max(currentState.questionStage, 3)
                            }
                        }
                        Button("Previous") {
                            withAnimation {
                                currentState.questionStage -= 1
                                currentState.questionStage = min(currentState.questionStage, 0)
                            }
                        }
                    }
                }
                
                Section("Received Answer") {
                    TextField(text: $answer) {
                        Text("Answer")
                    }
                    Button("Register correct answer") {
                        withAnimation {
                            question.wrappedValue.answered.toggle()
                            currentState.currentQuestion = nil
                        }
                        dismiss()
                    }
                    Button("Register wrong answer") {
                        withAnimation {
                            question.wrappedValue.answered.toggle()
                            currentState.currentQuestion = nil
                        }
                        dismiss()
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
        }
    }
}

struct QuestionControl_Previews: PreviewProvider {
    static var previews: some View {
        QuestionControl()
    }
}
