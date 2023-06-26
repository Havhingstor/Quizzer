import Foundation

struct Category: Identifiable, Hashable {
    var name: String
    private (set) var id = UUID()
    
    var isShown: Bool
    
    init(name: String) {
        self.name = name
        self.isShown = false
    }
}
