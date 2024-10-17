import Foundation

struct Category: Identifiable, Hashable, Codable {
    var name: String
    private(set) var id = UUID()
    
    var isShown: Bool
    
    init(name: String) {
        self.name = name
        self.isShown = false
    }
    
    enum CodingKeys: CodingKey {
        case name
        case id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.isShown = false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.id, forKey: .id)
    }
}
