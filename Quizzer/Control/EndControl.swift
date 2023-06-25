import SwiftUI

struct EndControl: View {
    @EnvironmentObject private var currentState: CurrentState
    @Environment(\.dismiss) var dismiss
    
    func getSortedTeamList() -> [(rank: Int, team: Team)] {
        var startRank = 1
        var lastPts = UInt(0)
        return currentState.getTeams().sorted { left, right in
            left.overallPoints > right.overallPoints
        }.map { team in
            if team.overallPoints < lastPts {
                startRank += 1
            }
            lastPts = team.overallPoints
            return (startRank, team)
        }
    }
    
    private var maxRank: Int {
        getSortedTeamList().max { lhs, rhs in
            lhs.rank < rhs.rank
        }?.rank ?? 0
    }
    
    func isTeamHidden(rank: Int, stage: Int) -> Bool {
        let orderRank = maxRank + 1 - rank
        
        if rank > 1 {
            return stage < orderRank
        } else {
            return stage < orderRank - 1
        }
    }
    
    func greyOutTeam(rank: Int) -> Bool {
        isTeamHidden(rank: rank, stage: currentState.resultsStage) &&
            isTeamHidden(rank: rank, stage: currentState.resultsStage + 1)
    }
    
    func isNextTeam(rank: Int) -> Bool {
        isTeamHidden(rank: rank, stage: currentState.resultsStage) &&
            !isTeamHidden(rank: rank, stage: currentState.resultsStage + 1)
    }
    
    func getForegroundStyle(rank: Int) -> some ShapeStyle {
        if greyOutTeam(rank: rank) {
            return AnyShapeStyle(.secondary)
        } else if isNextTeam(rank: rank) {
            return AnyShapeStyle(.red)
        } else {
            return AnyShapeStyle(.primary)
        }
    }
    
    var nextTeamStr: String {
        var rankDict = [Team: Int]()
        var teams = [Team]()
        
        for (rank, team) in getSortedTeamList() {
            rankDict[team] = rank
        }
        
        for team in currentState.getTeams() {
            if let rank = rankDict[team],
                isNextTeam(rank: rank) {
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
            }
            
            Text("Next:\n\(nextTeamStr)")
                .multilineTextAlignment(.center)
                .animation(.default, value: currentState.resultsStage)
                .frame(minHeight: 50)
                .padding()
            
            ForEach(Array(getSortedTeamList().reversed()), id: \.team) { (rank, team) in
                Text("\(rank): \(team.name) - \(team.overallPoints)")
                    .padding()
                    .foregroundStyle(getForegroundStyle(rank: rank))
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
