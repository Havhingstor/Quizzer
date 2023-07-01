import SwiftUI

struct NameSelectionSheet: View {
    @EnvironmentObject private var currentState: CurrentState
    @Environment(\.dismiss) private var dismiss
    
    @State private var newName = ""
    @State private var additionAlert = false
    
    var groundType: String
    var typeOfInteraction = "Add"
    var multiline = false
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
            if multiline {
                Text(groundType)
                TextEditor(text: $newName)
                    .frame(minHeight: 50)
            } else {
                TextField(groundType, text: $newName)
                    .onSubmit {
                        submit()
                    }
            }
            VStack {
                Button(typeOfInteraction) {
                    submit()
                }
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
        }
        .padding()
        .alert("This Name already exists!", isPresented: $additionAlert) {
            Button("OK", role: .cancel) {}
        }
        .frame(minWidth: 150)
    }
}

#Preview {
    let currentState = CurrentState.examples
    return NameSelectionSheet(groundType: "Team Name", additionFunc: currentState.addTeam)
        .environmentObject(currentState)
}
