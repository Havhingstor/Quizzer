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
