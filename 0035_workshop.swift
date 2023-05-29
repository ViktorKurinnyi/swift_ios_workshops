/*
Teaches Codable basics with JSONEncoder/Decoder strategies.
Covers ISO8601 dates, snake_case key decoding, pretty/sorted output, and round-trips.
Includes nested types, optionals, and default values without custom CodingKeys.
Everything prints so you can inspect the results quickly.
*/
import Foundation

struct Preferences: Codable {
    var newsletterOptIn: Bool = false
    var favoriteTags: [String] = []
}

struct User: Codable, Identifiable {
    var id: UUID
    var name: String
    var nickname: String?
    var joined: Date
    var score: Int
    var preferences: Preferences
}

let user = User(
    id: UUID(uuidString: "11111111-2222-3333-4444-555555555555")!,
    name: "Avery",
    nickname: nil,
    joined: Date(timeIntervalSince1970: 1_725_000_000),
    score: 9001,
    preferences: Preferences(newsletterOptIn: true, favoriteTags: ["swift", "playgrounds"])
)

let encoder = JSONEncoder()
encoder.dateEncodingStrategy = .iso8601
encoder.keyEncodingStrategy = .useDefaultKeys
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

if let data = try? encoder.encode(user) {
    print("encoded user JSON:")
    print(String(data: data, encoding: .utf8)!)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    decoder.keyDecodingStrategy = .useDefaultKeys
    if let round = try? decoder.decode(User.self, from: data) {
        print("round-trip equal name:", round.name == user.name)
        print("round-trip joined:", round.joined == user.joined)
        print("nickname present:", round.nickname as Any)
    }
}

let snakeJSON = """
{
  "id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
  "name": "Sam",
  "joined": "2025-07-20T12:34:56Z",
  "score": 123,
  "preferences": {
    "newsletter_opt_in": true,
    "favorite_tags": ["ios","swiftui","testing"]
  },
  "nickname": "sammy"
}
""".data(using: .utf8)!

struct SnakePreferences: Codable {
    var newsletterOptIn: Bool
    var favoriteTags: [String]
}

struct SnakeUser: Codable, Identifiable {
    var id: UUID
    var name: String
    var nickname: String?
    var joined: Date
    var score: Int
    var preferences: SnakePreferences
}

let snakeDecoder = JSONDecoder()
snakeDecoder.keyDecodingStrategy = .convertFromSnakeCase
snakeDecoder.dateDecodingStrategy = .iso8601

if let u2 = try? snakeDecoder.decode(SnakeUser.self, from: snakeJSON) {
    print("decoded snake_case user:", u2.name, u2.preferences.favoriteTags.count)
    let snakeEncoder = JSONEncoder()
    snakeEncoder.keyEncodingStrategy = .convertToSnakeCase
    snakeEncoder.dateEncodingStrategy = .iso8601
    snakeEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    if let back = try? snakeEncoder.encode(u2) {
        print("re-encoded snake_case:")
        print(String(data: back, encoding: .utf8)!)
    }
}

struct Event: Codable {
    var title: String
    var when: Date
    var durationSeconds: Int
}

let events: [Event] = [
    .init(title: "Kickoff", when: Date(timeIntervalSince1970: 1_725_432_100), durationSeconds: 1800),
    .init(title: "Wrap", when: Date(timeIntervalSince1970: 1_725_435_700), durationSeconds: 1200)
]

let eenc = JSONEncoder()
eenc.dateEncodingStrategy = .iso8601
eenc.outputFormatting = [.sortedKeys]
if let edata = try? eenc.encode(events) {
    print("events JSON compact sorted keys:")
    print(String(data: edata, encoding: .utf8)!)
    let edec = JSONDecoder()
    edec.dateDecodingStrategy = .iso8601
    if let decoded = try? edec.decode([Event].self, from: edata) {
        print("decoded events count:", decoded.count)
    }
}
