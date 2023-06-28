import Foundation

struct NamedData: Codable, Hashable {
    let name: String
    let hash: Int
    
    init(name: String, data: Data) {
        self.name = name
        self.hash = data.hashValue
        CurrentState.shared.storageContainer.images[hash] = data
    }
    
    var data: Data {
        CurrentState.shared.storageContainer.images[hash] ?? Data()
    }
}
