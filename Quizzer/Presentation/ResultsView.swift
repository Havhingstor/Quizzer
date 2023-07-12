import SwiftUI

struct ResultsView: View {
    var body: some View {
        VStack {
            ForEach(getSortedTeamList(), id: \.team) { (rank, orderNo, team) in
                TeamLine(team: team, rank: rank, orderNo: orderNo)
            }
        }
    }
}

struct TeamLine: View {
    @EnvironmentObject var currentState: CurrentState
    
    @ObservedObject var team: Team
    @State var rank: Int
    @State var orderNo: Int
    
    func getPointsStr(team: Team) -> String {
        let points = team.overallPoints
        if points == 1 {
            return "\(points) \(currentState.pointName)"
        } else {
            return "\(points) \(currentState.pointsName)"
        }
    }
    
    var body: some View {
        Text("\(rank): \(team.name) - \(getPointsStr(team: team))")
            .font(.custom("SF Pro", size: 44.0))
            .padding()
            .opaqueBackground()
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
            .hide(if: isTeamHidden(orderNo: orderNo, stage: currentState.resultsStage))
            .conditionalModifier({ view in
                if rank == 1 {
                    return view.transition(.asymmetric(insertion: .scale.animation(.spring(response: 0.65, dampingFraction: 0.45)), removal: .opacity.animation(.default)))
                } else {
                    return view.transition(.opacity.animation(.default))
                }
            })
    }
}
