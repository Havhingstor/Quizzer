import SwiftUI

struct GeneralFlowControls: View {
    @EnvironmentObject private var currentState: CurrentState
    @Environment(\.openWindow) private var openWindow
    
    @FocusState private var nextTeamFocus
    
    @State private var editShown = false
    
    func canCategoryBeShown() -> Bool {
        for category in currentState.categories {
            if !category.isShown {
                return true
            }
        }
        
        return false
    }
    
    func showNextCategory() {
        for (index, category) in currentState.categories.enumerated() {
            if !category.isShown {
                let key = currentState.lockReloading()
                withAnimation {
                    currentState.categories[index].isShown.toggle()
                }
                currentState.unlockReloading(id: key)
                return
            }
        }
    }
    
    func showResults() {
        withAnimation {
            currentState.showResults = true
        }
        openWindow(id: "rslt")
    }
    
    @ViewBuilder
    private var nextTeamPicker: some View {
        VStack {
            Text("Next Team")
            Picker("Next Team", selection: $currentState.nextTeam) {
                ForEach(currentState.getTeams()) { team in
                    Text("\(team.name)")
                        .tag(team)
                }
            }
            .labelsHidden()
            .focused($nextTeamFocus)
            .onAppear(perform: {
                nextTeamFocus = true
            })
        }
        .padding()
    }
    
    @ViewBuilder
    private var nextCategoryButton: some View {
        Button("Show next category") {
            showNextCategory()
        }
        .keyboardShortcut("#")
        .disabled(!canCategoryBeShown())
    }
    
    @ViewBuilder
    private var masterQuestionButtonAssembly: some View {
        Group {
            if !currentState.showMasterQuestion {
                masterQuestionButton
                    .disabled(!currentState.masterQuestionActivated)
                    .contextMenu {
                        if !currentState.masterQuestionActivated {
                            masterQuestionButton
                        }
                        Button("Edit Master Question") {
                            editShown = true
                        }
                    }
            } else {
                Button("Hide Master Question") {
                    withAnimation {
                        currentState.showMasterQuestion = false
                    }
                }
                .contextMenu {
                    Button("Edit Master Question") {
                        editShown = true
                    }
                }
            }
        }
        .sheet(isPresented: $editShown) {
            MasterQuestionEditView()
        }
    }
    
    @ViewBuilder
    private var masterQuestionButton: some View {
        Button("Show Master Question") {
            withAnimation {
                currentState.showMasterQuestion = true
            }
        }
    }
    
    @ViewBuilder
    private var resultsButtonAssembly: some View {
        if currentState.showResults {
            Button("Hide Results") {
                withAnimation {
                    currentState.showResults = false
                }
            }
        } else {
            resultsButton
                .disabled(!currentState.masterQuestionActivated)
                .contextMenu {
                    if !currentState.masterQuestionActivated {
                        resultsButton
                    }
                }
        }
    }
    
    @ViewBuilder
    private var resultsButton: some View {
        Button("Show Results") {
            showResults()
        }
    }
    
    var body: some View {
        nextTeamPicker
        
        VStack {
            nextCategoryButton
            masterQuestionButtonAssembly
            resultsButtonAssembly
        }
        .padding()
    }
}

#Preview {
    GeneralFlowControls()
        .fixedSize()
        .environmentObject(CurrentState.examples)
}
