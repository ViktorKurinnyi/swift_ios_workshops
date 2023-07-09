/**
 PropertyList Codable — Store structured settings with plists.
 Encode/decode nested types to XML plist files.
 Persist to disk and round-trip back into models.
*/

import Foundation

struct Appearance: Codable, Hashable {
    var theme: String
    var fontSize: Double
    var reduceMotion: Bool
}

struct Account: Codable, Hashable {
    var username: String
    var lastLogin: Date
    var favorites: [String]
}

struct Settings: Codable, Hashable, CustomStringConvertible {
    var version: Int
    var appearance: Appearance
    var flags: [String: Bool]
    var accounts: [Account]
    var description: String {
        let users = accounts.map(\.username).joined(separator: ", ")
        return "v\(version) • theme=\(appearance.theme) • users=[\(users)] • flags=\(flags.keys.sorted())"
    }
}

let base = FileManager.default.temporaryDirectory
let path = base.appendingPathComponent("settings.plist")

let settings = Settings(
    version: 1,
    appearance: .init(theme: "system", fontSize: 14, reduceMotion: false),
    flags: ["pro": true, "onboarding_done": false],
    accounts: [
        .init(username: "avery", lastLogin: Date(timeIntervalSince1970: 1_700_000_000), favorites: ["swift", "xcode"]),
        .init(username: "sam", lastLogin: Date(), favorites: ["ios"])
    ]
)

let encoder = PropertyListEncoder()
encoder.outputFormat = .xml
let data = try encoder.encode(settings)
try data.write(to: path, options: [.atomic])

let raw = try Data(contentsOf: path)
let decoder = PropertyListDecoder()
let loaded = try decoder.decode(Settings.self, from: raw)

print("Saved at:", path.path)
print("Loaded:", loaded.description)

var updated = loaded
updated.version += 1
updated.appearance.fontSize = 16
updated.flags["onboarding_done"] = true
updated.accounts = updated.accounts.map { acct in
    var next = acct
    if next.username == "sam" { next.favorites.append("widgets") }
    return next
}

let data2 = try encoder.encode(updated)
try data2.write(to: path, options: [.atomic])

let loaded2 = try decoder.decode(Settings.self, from: Data(contentsOf: path))
print("Updated:", loaded2.description)

struct LegacySettings: Codable {
    var theme: String
    var fontSize: Double
    var flags: [String: Bool]
}

let legacy = LegacySettings(theme: "dark", fontSize: 13, flags: ["pro": false])
let legacyData = try encoder.encode(legacy)
let legacyURL = base.appendingPathComponent("legacy.plist")
try legacyData.write(to: legacyURL, options: [.atomic])

let migrated: Settings = {
    if let d = try? Data(contentsOf: legacyURL),
       let old = try? decoder.decode(LegacySettings.self, from: d) {
        return Settings(
            version: 1,
            appearance: .init(theme: old.theme, fontSize: old.fontSize, reduceMotion: false),
            flags: old.flags,
            accounts: []
        )
    } else {
        return settings
    }
}()

print("Migrated:", migrated.description)
