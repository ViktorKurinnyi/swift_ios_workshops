/*
Struct Initialization Patterns
Use memberwise, custom convenience, and failable initializers.
Build small types with validation and defaults to keep data correct.
See how initializers compose cleanly without external assets.
*/

import Foundation

struct RGBA {
    var r: Double
    var g: Double
    var b: Double
    var a: Double
}

extension RGBA {
    var hex: String {
        let clamp = { (x: Double) -> Int in max(0, min(255, Int(x * 255))) }
        return String(format: "#%02X%02X%02X%02X", clamp(r), clamp(g), clamp(b), clamp(a))
    }
}

struct Email {
    let raw: String
    init?(_ raw: String) {
        let parts = raw.split(separator: "@")
        guard parts.count == 2, parts[1].contains(".") else { return nil }
        self.raw = raw
    }
}

struct User {
    let id: UUID
    var name: String
    var email: Email?
    init(name: String, email: String?) {
        self.id = UUID()
        self.name = name
        self.email = email.flatMap(Email.init)
    }
    init(id: UUID, name: String) {
        self.id = id
        self.name = name
        self.email = nil
    }
    init?(dictionary: [String: String]) {
        guard let name = dictionary["name"] else { return nil }
        self.id = UUID()
        self.name = name
        if let e = dictionary["email"] { self.email = Email(e) } else { self.email = nil }
    }
}

print("=== Memberwise RGBA ===")
let red = RGBA(r: 1, g: 0, b: 0, a: 1)
let green = RGBA(r: 0, g: 1, b: 0, a: 1)
print("Red hex:", red.hex, "Green hex:", green.hex)

print("=== Custom initializers with defaults and transforms ===")
let alice = User(name: "Alice", email: "alice@example.com")
let bob = User(name: "Bob", email: nil)
print("Alice email:", alice.email?.raw ?? "nil")
print("Bob email:", bob.email?.raw ?? "nil")

print("=== Alternate init paths ===")
let fixedID = UUID()
let eve = User(id: fixedID, name: "Eve")
print("Eve:", eve.id, eve.name)

print("=== Failable initializer for Email ===")
print("Good:", Email("a@b.com")?.raw ?? "nil")
print("Bad:", Email("invalid")?.raw ?? "nil")

print("=== Dictionary-based init ===")
let maybeUser = User(dictionary: ["name": "Zed", "email": "zed@host.tld"])
print("From dict:", maybeUser?.name ?? "nil", maybeUser?.email?.raw ?? "nil")

print("=== Build a palette ===")
let palette = [
    RGBA(r: 0.2, g: 0.3, b: 0.8, a: 1),
    RGBA(r: 0.9, g: 0.8, b: 0.1, a: 1),
    RGBA(r: 0.1, g: 0.7, b: 0.6, a: 1)
]
print("Palette hex:", palette.map { $0.hex })
