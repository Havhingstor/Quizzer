import Foundation
import ZIPFoundation

struct NamedData: Codable, Hashable {
    let name: String
    let data: Data
    
    enum CodingKeys: CodingKey {
        case name
        case data
        case checksum
    }
    
    init(name: String, data: Data) {
        self.name = name
        self.data = data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let zippedData = try container.decode(Data.self, forKey: .data)
        let storedChecksum = try container.decode(CRC32.self, forKey: .checksum)
        
        guard let archive = Archive(data: zippedData, accessMode: .read),
            let entry = archive["image"] else {throw DataError.ImageCouldNotBeDecompressed}
        
        var decompressedData = Data()
        
        let checksum = try archive.extract(entry, consumer: { data in
            decompressedData.append(data)
        })
        
        guard checksum == storedChecksum else { throw DataError.ImageCouldNotBeDecompressed }
        
        self.name = try container.decode(String.self, forKey: .name)
        self.data = decompressedData
    }
    
    func encode(to encoder: Encoder) throws {
        let archive = Archive(accessMode: .create)
        try archive?.addEntry(with: "image", type: .file, uncompressedSize: Int64(data.count), compressionMethod: .deflate) { position, size in
            return data.subdata(in: Int(position) ..< Int(position)+size)
        }
        
        guard let checksum = archive?["image"]?.checksum else {throw DataError.ImageCouldNotBeCompressed}
        
        guard let zippedData = archive?.data else { throw DataError.ImageCouldNotBeCompressed }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(zippedData, forKey: .data)
        try container.encode(checksum, forKey: .checksum)
    }
}

enum DataError: Error {
    case ImageCouldNotBeCompressed
    case ImageCouldNotBeDecompressed
}
