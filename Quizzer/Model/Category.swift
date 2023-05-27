import Foundation

struct Category: Identifiable {
    let name: String
    var id: String {name}
    var isShown: Bool
    
    init(name: String, isShown: Bool) {
        self.name = name
        self.isShown = isShown
    }
}
