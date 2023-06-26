import Foundation

struct NamedData: Codable, Hashable {
    let name: String
    let data: Data
}
