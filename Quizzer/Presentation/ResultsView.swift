import SwiftUI

struct ResultsView: View {
    @EnvironmentObject private var currentState: CurrentState
    
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
    
    func hideTeam(rank: Int) -> Bool {
        let orderRank = maxRank + 1 - rank
        
        if rank > 1 {
            return currentState.resultsStage < orderRank
        } else {
            return currentState.resultsStage < orderRank - 1
        }
    }
    
    func getPointsStr(team: Team) -> String {
        let points = team.overallPoints
        if points == 1 {
            return "\(points) \(currentState.pointName)"
        } else {
            return "\(points) \(currentState.pointsName)"
        }
    }
    
    var body: some View {
        VStack {
            ForEach(getSortedTeamList(), id: \.team) { (rank, team) in
                Text("\(rank): \(team.name) - \(getPointsStr(team: team))")
                    .font(.custom("SF Pro", size: 44.0))
                    .padding()
                    .background(.gray.opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
                    .padding([.top, .trailing], 20)
                    .overlay(alignment: .topTrailing, content: {
                        if rank == 1 {
                            Image(systemName: "star.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 75)
                                .foregroundStyle(.yellow)
                                .rotationEffect(.radians(.pi / 6.0))
                        }
                    })
                    .hide(if: hideTeam(rank: rank))
            }
        }
    }
}

#Preview {
    ResultsView()
}
