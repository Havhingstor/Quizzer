import SwiftUI

struct AddTeamSheet: View {
    @EnvironmentObject private var currentState: CurrentState
    @Environment(\.dismiss) private var dismiss
    
    @State private var newTeamName = ""
    @State private var teamAdditionAlert = false
    
    func addTeam() {
        do {
            try currentState.addTeam(name: newTeamName)
            dismiss()
        } catch {
            teamAdditionAlert = true
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Team Name", text: $newTeamName)
                .onSubmit {
                    addTeam()
                }
            Button("Add") {
                addTeam()
            }
        }
        .padding()
        .alert("This Name already exists!", isPresented: $teamAdditionAlert) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        }
    }
}

#Preview {
    AddTeamSheet()
        .environmentObject(CurrentState.examples)
}
