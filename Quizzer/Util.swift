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
}
