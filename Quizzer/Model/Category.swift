import Foundation

struct Category: Identifiable {
    let name: String
    var id: String {name}
    var isShown: Bool
    
    init(name: String) {
        self.name = name
        self.isShown = false
    }
}
