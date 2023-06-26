import SwiftUI

struct NameSelectionSheet: View {
    @EnvironmentObject private var currentState: CurrentState
    @Environment(\.dismiss) private var dismiss
    
    @State private var newName = ""
    @State private var additionAlert = false
    
    var groundType: String
    var typeOfInteraction = "Add"
    var additionFunc: (String) throws -> Void
    
    func submit() {
        do {
            try withAnimation {
                try additionFunc(newName)
            }
            dismiss()
        } catch {
            additionAlert = true
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("\(groundType) Name", text: $newName)
                .onSubmit {
                    submit()
                }
            Button(typeOfInteraction) {
                submit()
            }
            Button("Cancel", role: .cancel) {
                dismiss()
            }
        }
        .padding()
        .alert("This Name already exists!", isPresented: $additionAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}

#Preview {
    let currentState = CurrentState.examples
    return NameSelectionSheet(groundType: "Team", additionFunc: currentState.addTeam)
        .environmentObject(currentState)
}
