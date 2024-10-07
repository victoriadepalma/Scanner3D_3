import Foundation
import FirebaseFirestoreSwift

struct InventoryItem: Identifiable, Codable, Equatable {
    
    var id: String // This will hold the `_id` value from the JSON
    
    // ServerTimestamp properties need to be optional as they may not be included when decoding
//    @ServerTimestamp var createdAt: Date?
//    @ServerTimestamp var updatedAt: Date?
    
    var name: String
    var quantity: Int
    var userId: String
    
    var usdzLink: String?
    var usdzURL: URL? {
        guard let usdzLink else { return nil }
        return URL(string: usdzLink)
    }
    
    var thumbnailLink: String?
    var thumbnailURL: URL? {
        guard let thumbnailLink else { return nil }
        return URL(string: thumbnailLink)
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id" // Maps the JSON key `_id` to the `id` property
        case name
        case quantity
        case userId
        case usdzLink
        case thumbnailLink
//        case createdAt
//        case updatedAt
    }
}
