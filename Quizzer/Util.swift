import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func hide(if condition: Bool) -> some View {
        if condition {
            hidden()
        } else {
            self
        }
    }
    
    @ViewBuilder
    func opaqueBackground() -> some View {
        let opacity = 0.85
        background(.gray.opacity(opacity))
    }
    
    @ViewBuilder
    func conditionalModifier(_ modifiers: (any View) -> any View) -> some View {
        AnyView(modifiers(self))
    }
}


func getSortedTeamList() -> [(rank: Int, orderNo: Int, team: Team)] {
    var startRank = 1
    var overallCount = 1
    var lastPts = UInt(0)
    
    let list = CurrentState.shared.getTeams().sorted { left, right in
        left.overallPoints > right.overallPoints
    }.map { team in
        if team.overallPoints < lastPts {
            startRank = overallCount
        }
        lastPts = team.overallPoints
        overallCount += 1
        return (startRank, team)
    }
    
    var index = 0
    var lastRank = -1
    var didTwoExists = false
    
    return list.reversed().map { rank, team in
        if rank == 2 {
            didTwoExists = true
        }
        
        if rank != lastRank {
            index += 1
            lastRank = rank
            
            if rank == 1 && didTwoExists {
                index -= 1
            }
        }
        
        return (rank, index, team)
    }.reversed()
}

func isTeamHidden(orderNo: Int, stage: Int) -> Bool {
    stage < orderNo
}
