/*
Regex Builder Basics — Parse text with type-safe literals and DSL components.
Use Swift regex literals for quick wins and RegexBuilder for typed captures.
Extract key–value pairs, validate ISO dates, and build structured data.
No third-party libs; just Standard Library + RegexBuilder.
*/
import Foundation
import RegexBuilder

func section(_ title: String) { print("\n=== \(title) ===") }

section("Literal Regex: Key–Value Pairs")
let lines = [
    "name: Ana García; age: 29; email: ana@example.com",
    "name: Luis; age: 34; email: luis@example.es",
    "name: Marta; age: 27; email: marta@example.io"
]
let kv = /(\w+):\s*(.*?)(?=;|$)/
var records: [[String: String]] = []
for line in lines {
    var dict: [String: String] = [:]
    for m in line.matches(of: kv) {
        let key = String(m.1)
        let val = String(m.2)
        dict[key] = val
    }
    records.append(dict)
}
print("records:", records)

section("RegexBuilder: ISO Date with Typed Captures")
// Keep the builder simple for the type checker; parse Ints after matching.
let isoDate = Regex {
    Capture { Repeat(count: 4) { .digit } }
    "-"
    Capture { Repeat(count: 2) { .digit } }
    "-"
    Capture { Repeat(count: 2) { .digit } }
}
let dates = ["2025-08-31", "1999-12-31", "2025-02-29"]
for d in dates {
    if let m = d.firstMatch(of: isoDate),
       let y = Int(String(m.1)),
       let mo = Int(String(m.2)),
       let day = Int(String(m.3)) {
        var comps = DateComponents()
        comps.year = y
        comps.month = mo
        comps.day = day
        let ok = Calendar(identifier: .gregorian).date(from: comps) != nil
        print(d, "valid:", ok)
    } else {
        print(d, "no match")
    }
}

section("RegexBuilder: Phone Pattern with Alternatives")
let phone = Regex {
    // Optional leading "+"; country code captured as digits
    Optionally { "+" }
    Capture { OneOrMore { .digit } }
    ChoiceOf { "-" ; " " }
    Capture { Repeat(count: 3) { .digit } }
    ChoiceOf { "-" ; " " }
    Capture { Repeat(count: 3) { .digit } }
    ChoiceOf { "-" ; " " }
    Capture { Repeat(count: 3) { .digit } }
}
let phones = ["+34-600-123-456", "+34 600 123 456", "600123456"]
for p in phones {
    if let m = p.firstMatch(of: phone) {
        let country = String(m.1)
        let a = String(m.2)
        let b = String(m.3)
        let c = String(m.4)
        print("parsed:", p, "→", country, a, b, c)
    } else {
        print("no match:", p)
    }
}

section("Regex Composition: Email Rough Check")
let local = Regex { OneOrMore { .word } }
let hostLabel = Regex { OneOrMore { .word } }
let dot = "."
let email = Regex {
    Anchor.startOfLine
    Capture { local }
    "@"
    Capture { hostLabel }
    dot
    Capture { hostLabel }
    Anchor.endOfLine
}
let emails = ["ana@example.com", "bad@host", "john.doe@example.co"]
for e in emails {
    if let m = e.firstMatch(of: email) {
        print("ok:", e, "user:", String(m.1), "domain:", String(m.2), "tld:", String(m.3))
    } else {
        print("reject:", e)
    }
}

section("From Matches to Strong Types")
struct Person {
    var name: String
    var age: Int
    var email: String
}
let people: [Person] = records.compactMap { r in
    guard let name = r["name"], let age = r["age"].flatMap(Int.init), let email = r["email"] else { return nil }
    return Person(name: name, age: age, email: email)
}
print("people:", people.map { "\($0.name)(\($0.age))" })
