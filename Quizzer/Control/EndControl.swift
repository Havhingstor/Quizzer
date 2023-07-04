import SwiftUI

struct EndControl: View {
    @EnvironmentObject private var currentState: CurrentState
    @Environment(\.dismiss) private var dismiss
    
    func greyOutTeam(orderNo: Int) -> Bool {
        isTeamHidden(orderNo: orderNo, stage: currentState.resultsStage) &&
            isTeamHidden(orderNo: orderNo, stage: currentState.resultsStage + 1)
    }
    
    func isNextTeam(orderNo: Int) -> Bool {
        isTeamHidden(orderNo: orderNo, stage: currentState.resultsStage) &&
            !isTeamHidden(orderNo: orderNo, stage: currentState.resultsStage + 1)
    }
    
    func getForegroundStyle(orderNo: Int) -> some ShapeStyle {
        if greyOutTeam(orderNo: orderNo) {
            return AnyShapeStyle(.secondary)
        } else if isNextTeam(orderNo: orderNo) {
            return AnyShapeStyle(.red)
        } else {
            return AnyShapeStyle(.primary)
        }
    }
    
    var nextTeamStr: String {
        var rankDict = [Team: Int]()
        var teams = [Team]()
        
        for (_, orderNo, team) in getSortedTeamList() {
            rankDict[team] = orderNo
        }
        
        for team in currentState.getTeams() {
            if let orderNo = rankDict[team],
                isNextTeam(orderNo: orderNo) {
                teams.append(team)
            }
        }
        
        var result = ""
        
        if let last = teams.last {
            for index in 0 ..< teams.count - 1 {
                result.append("\(teams[index].name), \n")
            }
            
            result.append(last.name)
        } else {
            result = "N/A"
        }
        
        return result
        
    }
    
    var maxOrderNo: Int {
        getSortedTeamList().max { lhs, rhs in
            lhs.orderNo < rhs.orderNo
        }?.orderNo ?? 0
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("Hide") {
                    currentState.resultsStage -= 1
                }
                .disabled(currentState.resultsStage < 1)
                Button("Show") {
                    currentState.resultsStage += 1
                }
                .disabled(currentState.resultsStage >= maxOrderNo)
            }
            
            Text("Next:\n\(nextTeamStr)")
                .multilineTextAlignment(.center)
                .animation(.default, value: currentState.resultsStage)
                .frame(minHeight: 50)
                .padding()
            
            ForEach(Array(getSortedTeamList().reversed()), id: \.team) { (rank, orderNo, team) in
                Text("\(rank): \(team.name) - \(team.overallPoints)")
                    .padding()
                    .foregroundStyle(getForegroundStyle(orderNo: orderNo))
            }
        }
        .padding()
        .onChange(of: currentState.showResults) { oldValue, newValue in
            if !newValue {
                dismiss()
            }
        }
        .fixedSize()
    }
}

#Preview {
    EndControl().environmentObject(CurrentState.examples)
}
