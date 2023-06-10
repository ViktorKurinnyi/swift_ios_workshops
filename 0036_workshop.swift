/**
 Codable Custom Keys — Map snake_case payloads with CodingKeys.
 Learn to map JSON keys to Swift property names explicitly.
 Decode, transform, and encode back to snake_case.
*/

import Foundation

let json = """
{
  "id": 42,
  "full_name": "Avery Doe",
  "joined_at": "2024-11-05T10:30:00Z",
  "is_active": true,
  "address": {
    "street_name": "Market St",
    "house_number": "101",
    "postal_code": "94103",
    "city_name": "San Francisco"
  },
  "tags": ["pro", "beta_user"],
  "stats": {
    "login_count": 17,
    "avg_session_seconds": 245.7
  }
}
"""

struct Address: Codable, Hashable {
    let streetName: String
    let houseNumber: String
    let postalCode: String
    let cityName: String
    enum CodingKeys: String, CodingKey {
        case streetName = "street_name"
        case houseNumber = "house_number"
        case postalCode = "postal_code"
        case cityName = "city_name"
    }
    var line: String { "\(houseNumber) \(streetName), \(cityName) \(postalCode)" }
}

struct Stats: Codable, Hashable {
    let loginCount: Int
    let avgSessionSeconds: Double
    enum CodingKeys: String, CodingKey {
        case loginCount = "login_count"
        case avgSessionSeconds = "avg_session_seconds"
    }
}

struct User: Codable, CustomStringConvertible, Identifiable, Hashable {
    let id: Int
    let fullName: String
    let joinedAt: Date
    let isActive: Bool
    let address: Address
    let tags: [String]
    let stats: Stats
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case joinedAt = "joined_at"
        case isActive = "is_active"
        case address, tags, stats
    }
    var description: String {
        let day = DateFormatter.localizedString(from: joinedAt, dateStyle: .medium, timeStyle: .short)
        return "#\(id) \(fullName) • \(isActive ? "active" : "inactive") • since \(day)\n\(address.line)\nTags: \(tags.joined(separator: ", "))\nLogins: \(stats.loginCount)"
    }
}

let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
let data = Data(json.utf8)
let user = try decoder.decode(User.self, from: data)

print("Decoded:")
print(user.description)

struct Patch: Encodable {
    let id: Int
    let newTag: String
    enum CodingKeys: String, CodingKey {
        case id
        case newTag = "new_tag"
    }
}

let patch = Patch(id: user.id, newTag: "swift")
let patchEncoder = JSONEncoder()
patchEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
let patchData = try patchEncoder.encode(patch)
print("\nPatch Payload:")
print(String(data: patchData, encoding: .utf8)!)

var enriched = user
let extra = ["swift", "ios", "playgrounds"]
let merged = Array(Set(enriched.tags + extra)).sorted()
struct Upsert: Codable {
    let id: Int
    let tags: [String]
    let address: Address
    enum CodingKeys: String, CodingKey {
        case id
        case tags
        case address
    }
}
let upsert = Upsert(id: enriched.id, tags: merged, address: enriched.address)

let encoder = JSONEncoder()
encoder.dateEncodingStrategy = .iso8601
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
let fullData = try encoder.encode(upsert)
print("\nUpsert Payload:")
print(String(data: fullData, encoding: .utf8)!)

let roundtrip = try decoder.decode(Upsert.self, from: fullData)
print("\nRoundtrip Tags:", roundtrip.tags.joined(separator: ","))

let addressBook = [user.address, Address(streetName: "Main Ave", houseNumber: "7B", postalCode: "10001", cityName: "New York")]
let uniqueCities = Set(addressBook.map { $0.cityName }).sorted()
print("\nCities:", uniqueCities.joined(separator: " • "))
