import SwiftUI

struct GeneralControl: View {
    @EnvironmentObject private var currentState: CurrentState    
    var width = 250.0

    var body: some View {
        VStack {
            GeneralFlowControls()
            Spacer()
            TeamView()
            Spacer()
        }
        .frame(width: width)
    }
}

#Preview {
    GeneralControl()
        .environmentObject(CurrentState.examples)
}
