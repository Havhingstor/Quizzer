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
    
    func opaqueBackground() -> some View {
        let opacity = 0.85
        
        return background(.gray.opacity(opacity))
    }
}
